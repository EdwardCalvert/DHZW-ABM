package main.java.nl.uu.iss.ga.simulation.agent.plan.activity;

import main.java.nl.uu.iss.ga.model.data.*;
import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;

import main.java.nl.uu.iss.ga.model.data.dictionary.TwoStringKeys;
import main.java.nl.uu.iss.ga.model.interfaces.IUtilityFunctionStrategy;
import main.java.nl.uu.iss.ga.model.reader.MNLparametersReader;
import main.java.nl.uu.iss.ga.model.reader.ParameterReader;
import main.java.nl.uu.iss.ga.simulation.agent.context.BeliefContext;
import main.java.nl.uu.iss.ga.simulation.agent.context.RoutingBusBeliefContext;
import main.java.nl.uu.iss.ga.simulation.agent.context.RoutingSimmetricBeliefContext;
import main.java.nl.uu.iss.ga.simulation.agent.context.RoutingTrainBeliefContext;
import main.java.nl.uu.iss.ga.simulation.utilityfunctions.SttStrategy;
import main.java.nl.uu.iss.ga.simulation.utilityfunctions.UtilFunctionProvider;
import main.java.nl.uu.iss.ga.util.CumulativeDistribution;
import main.java.nl.uu.iss.ga.util.MNLModalChoiceModel;
import nl.uu.cs.iss.ga.sim2apl.core.agent.PlanToAgentInterface;
import nl.uu.cs.iss.ga.sim2apl.core.plan.builtin.RunOncePlan;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.logging.Level;
import java.util.logging.Logger;


public class ExecuteTourPlan extends RunOncePlan<TripTour> {
    private static final Logger LOGGER = Logger.getLogger(MNLparametersReader.class.getName());
    private final ActivityTour activityTour;
    private final long pid;
    private final long hid;
    private final Random _random;
    private TripTour tripTour;

    public ExecuteTourPlan(ActivityTour activityTour, Random random) {
        this.activityTour = activityTour;
        this.pid = activityTour.getPid();
        this.hid = activityTour.getHid();
        this._random = random;
    }

    /**
     * This function is called at every midnight for each action of the next day.
     *
     * @param planToAgentInterface
     * @return
     */
    @Override
    public TripTour executeOnce(PlanToAgentInterface<TripTour> planToAgentInterface) {
        List<Activity> activities = activityTour.getActivityTour();
        this.tripTour = new TripTour(activityTour.getPid(), activityTour.getDay());
        Person person = planToAgentInterface.getContext(Person.class);

        // only agents that are older than 4 years old can decide their activities
        if (person.getAge() >= 4) {

            BeliefContext beliefContext = planToAgentInterface.getContext(BeliefContext.class);
            IUtilityFunctionStrategy utilityFunction = planToAgentInterface.getContext(UtilFunctionProvider.class).getUtilityFunction();
            if(utilityFunction == null){
                throw new RuntimeException("No Utility Function supplied");
            }

            HashMap<TransportMode, Double> travelTimes = new HashMap<>();
            HashMap<TransportMode, Double> travelDistances = new HashMap<>();

            int nChangesBus = 0;
            int nChangesTrain = 0;
            double walkTimeBus = 0;
            double walkTimeTrain = 0;
            double busTimeTrain = 0;
            double busDistanceTrain = 0;

            boolean trainPossible = false;
            boolean busPossible = false;
            boolean walkPossible = false;
            boolean bikePossible = false;
            boolean carDriverPossible = false;
            boolean carPassengerPossible = false;

            RoutingSimmetricBeliefContext routingSymmetric = planToAgentInterface.getContext(RoutingSimmetricBeliefContext.class);
            RoutingBusBeliefContext routingBus = planToAgentInterface.getContext(RoutingBusBeliefContext.class);
            RoutingTrainBeliefContext routingTrain = planToAgentInterface.getContext(RoutingTrainBeliefContext.class);

            /*
             *  generation of transport mode for each trip
             */
            Activity activityOrigin = activities.get(0);

            // initialise the trip tour
            for (Activity activityDestination : activities.subList(1, activities.size())) {
                // not entirely outside DHZW and the postcodes are different
                if ((activityOrigin.getLocation().isInDHZW() || activityDestination.getLocation().isInDHZW()) && (
                        !activityOrigin.getLocation().getPostcode().equals(activityDestination.getLocation().getPostcode()))) {

                    TwoStringKeys simmetricPostcodes = new TwoStringKeys(
                            activityOrigin.getLocation().getPostcode(),
                            activityDestination.getLocation().getPostcode()
                    );

                    Trip trip = new Trip(this.pid,
                            this.hid,
                            activityOrigin,
                            activityDestination,
                            routingSymmetric.getBeelineDistance(simmetricPostcodes)
                    );
                    this.tripTour.addTrip(trip);
                }
                activityOrigin = activityDestination;
            }

            // sort by euclidean distance
            this.tripTour.sortTripsByDistance();

            // initialise the first mode with walk, so it does not catch the if condition just below
            TransportMode firstMode = TransportMode.WALK;

            // go through the trips
            for (Trip trip : this.tripTour.getTripChain()) {
                // if the first mode was the car driver, the whole chain is by that mode
                if (tripTour.getTripChain().indexOf(trip) != 0 && firstMode.equals(TransportMode.CAR_DRIVER)) {
                    trip.setTransportMode(TransportMode.CAR_DRIVER);

                    //String departurePostcode = trip.getDepartureActivity().getLocation().getPostcode();
                    //String arrivalPostcode = trip.getArrivalActivity().getLocation().getPostcode();
                    //TwoStringKeys symmetricPostcodes = new TwoStringKeys(departurePostcode, arrivalPostcode);
                    //double distance = routingSymmetric.getCarDistance(symmetricPostcodes);
                    //trip.setDistance(distance);
                    trip.setDistance(100);

                    beliefContext.getModeOfTransportTracker().notifyTransportModeUsed(
                            TransportMode.CAR_DRIVER,
                            beliefContext.getToday(),
                            trip.getArrivalActivity().getActivityType(),
                            person.hasCarLicense(),
                            person.getHousehold().hasCarOwnership(),
                            trip.getBeelineDistance(),
                            person.getHousehold().getIncomeThird()
                    );
                } else {
                    // either first trip of the chain, either the car driver was not chosen as first mode

                    String departurePostcode = trip.getDepartureActivity().getLocation().getPostcode();
                    String arrivalPostcode = trip.getArrivalActivity().getLocation().getPostcode();
                    boolean departureInDHZW = trip.getDepartureActivity().getLocation().isInDHZW();
                    boolean arrivalInDHZW = trip.getArrivalActivity().getLocation().isInDHZW();

                    //Set state at start of each trip to prevent state leakage.
                    walkPossible = false;
                    bikePossible = false;
                    carDriverPossible = false;
                    carPassengerPossible = false;
                    busPossible = false;
                    trainPossible = false;
                    // reset flags for the upcoming trip
                    travelTimes.clear();
                    travelDistances.clear();

                    TwoStringKeys symmetricPostcodes = new TwoStringKeys(departurePostcode, arrivalPostcode);
                    //
                    //FIXME!!!!!!!!
                    //The disabling of modes for longer trips should only be made for the "vot" utility funciont.
                    //
                    if (routingSymmetric.getWalkTime(symmetricPostcodes) != -1.0 && routingSymmetric.getWalkDistance(symmetricPostcodes)<5.0) {
                        walkPossible = true;
                        travelTimes.put(TransportMode.WALK, routingSymmetric.getWalkTime(symmetricPostcodes));
                        travelDistances.put(TransportMode.WALK, routingSymmetric.getWalkDistance(symmetricPostcodes));
                    }
                    if (routingSymmetric.getBikeTime(symmetricPostcodes) != -1.0&& routingSymmetric.getBikeDistance(symmetricPostcodes) < 15.0) {
                        bikePossible = true;
                        travelTimes.put(TransportMode.BIKE, routingSymmetric.getBikeTime(symmetricPostcodes));
                        travelDistances.put(TransportMode.BIKE, routingSymmetric.getWalkDistance(symmetricPostcodes));
                    }

                    // if trip is feasible by car and the household has a car, the agent can be passenger
                    if (routingSymmetric.getCarDistance(symmetricPostcodes) != -1.0 && person.getHousehold().hasCarOwnership()) {
                        carPassengerPossible = true;
                        travelTimes.put(TransportMode.CAR_PASSENGER, routingSymmetric.getCarTime(symmetricPostcodes));
                        travelDistances.put(TransportMode.CAR_PASSENGER, routingSymmetric.getCarDistance(symmetricPostcodes));
                    }
                    // car is either chosen at the beginning or never anymore. If it is taken at the first round, it is automatically applied to all the other trips.
                    if (tripTour.getTripChain().indexOf(trip) == 0
//                            && person.hasCarLicense()
                            && person.getHousehold().hasCarOwnership()
                            && routingSymmetric.getCarTime(symmetricPostcodes) != -1.0) {
                        carDriverPossible = true;
                        travelTimes.put(TransportMode.CAR_DRIVER, routingSymmetric.getCarTime(symmetricPostcodes));
                        travelDistances.put(TransportMode.CAR_DRIVER, routingSymmetric.getCarDistance(symmetricPostcodes));
                    }

                    if (routingBus.getFeasibleFlag(departurePostcode, arrivalPostcode) != -1) {
                        busPossible = true;
                        travelTimes.put(TransportMode.BUS_TRAM, routingBus.getBusTime(departurePostcode, arrivalPostcode));
                        travelDistances.put(TransportMode.BUS_TRAM, routingBus.getBusDistance(departurePostcode, arrivalPostcode));
                        nChangesBus = routingBus.getChange(departurePostcode, arrivalPostcode);
                        walkTimeBus = routingBus.getWalkTime(departurePostcode, arrivalPostcode);
                    }

                    // if the trip is partially outside, the train could be possible
                    if (departureInDHZW ^ arrivalInDHZW && routingTrain.getFeasibleFlag(departurePostcode, arrivalPostcode) != -1) {   // XOR operator
                        trainPossible = true;
                        travelTimes.put(TransportMode.TRAIN, routingTrain.getTrainTime(departurePostcode, arrivalPostcode));
                        travelDistances.put(TransportMode.TRAIN, routingTrain.getTrainDistance(departurePostcode, arrivalPostcode));
                        nChangesTrain = routingTrain.getChange(departurePostcode, arrivalPostcode);
                        walkTimeTrain = routingTrain.getWalkTime(departurePostcode, arrivalPostcode);
                        busTimeTrain = routingTrain.getBusTime(departurePostcode, arrivalPostcode);
                        busDistanceTrain = routingTrain.getBusDistance(departurePostcode, arrivalPostcode);

                    }
                    //Ensure that one mode is possible before attempting to assign a probability.
                    if(walkPossible|| bikePossible||carDriverPossible||carPassengerPossible||busPossible||trainPossible) {
                        // compute choice probabilities
                        Map<TransportMode, Double> choiceProbabilities = utilityFunction.getChoiceProbabilities(
                                walkPossible,
                                bikePossible,
                                carDriverPossible,
                                carPassengerPossible,
                                busPossible,
                                trainPossible,
                                travelTimes,
                                travelDistances,
                                walkTimeBus,
                                nChangesBus,
                                walkTimeTrain,
                                busTimeTrain,
                                busDistanceTrain,
                                nChangesTrain,
                                person,
                                trip
                        );

                        // decide the modal choice
                        TransportMode transportMode = CumulativeDistribution.sampleWithCumulativeDistribution(choiceProbabilities, _random);
                        trip.setTransportMode(transportMode);

                        double distance = 0;
//                    if (transportMode.equals(TransportMode.WALK) | transportMode.equals(TransportMode.BIKE) | transportMode.equals(TransportMode.CAR_PASSENGER) | transportMode.equals(TransportMode.CAR_DRIVER)) {
//                        distance = travelDistances.get(transportMode);
//                    } else if (transportMode.equals(TransportMode.BUS_TRAM)) {
//                        distance = routingBus.getTotalDistance(departurePostcode, arrivalPostcode);
//                    } else {
//                        distance = routingTrain.getTotalDistance(departurePostcode, arrivalPostcode);
//                    }
                        trip.setDistance(0);

                        beliefContext.getModeOfTransportTracker().notifyTransportModeUsed(
                                transportMode,
                                beliefContext.getToday(),
                                trip.getArrivalActivity().getActivityType(),
                                person.hasCarLicense(),
                                person.getHousehold().hasCarOwnership(),
                                trip.getDistance(),
                                person.getHousehold().getIncomeThird()
                        );


                        if (tripTour.getTripChain().indexOf(trip) == 0) {
                            firstMode = transportMode;
                        }
                    }
                }

            }

        }
        return this.tripTour;
    }

}
