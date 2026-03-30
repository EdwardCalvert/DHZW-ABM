package main.java.nl.uu.iss.ga.simulation.modalpolicies;

import main.java.nl.uu.iss.ga.model.data.Person;
import main.java.nl.uu.iss.ga.model.data.Trip;
import main.java.nl.uu.iss.ga.model.data.TripTour;
import main.java.nl.uu.iss.ga.model.data.dictionary.ModeAttributes;
import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import main.java.nl.uu.iss.ga.model.data.dictionary.TwoStringKeys;
import main.java.nl.uu.iss.ga.simulation.agent.context.BeliefContext;
import main.java.nl.uu.iss.ga.simulation.agent.context.RoutingBusBeliefContext;
import main.java.nl.uu.iss.ga.simulation.agent.context.RoutingSimmetricBeliefContext;
import main.java.nl.uu.iss.ga.simulation.agent.context.RoutingTrainBeliefContext;
import main.java.nl.uu.iss.ga.simulation.utilityfunctions.IUtilityFunctionStrategy;
import main.java.nl.uu.iss.ga.util.CumulativeDistribution;
import main.java.nl.uu.iss.ga.util.NormaliseProbability;

import java.util.Map;
import java.util.Random;

public class SequentialModalSelectionPolicy implements IModalSelectionPolicy {
    private final Random _random;
    public SequentialModalSelectionPolicy(Random random){
        this._random =random;
    }
    public void assignModes(TripTour tripTour,
                            Person person,
                            BeliefContext beliefContext,
                            RoutingSimmetricBeliefContext routingSymmetric,
                            RoutingBusBeliefContext routingBus,
                            RoutingTrainBeliefContext routingTrain,
                            IUtilityFunctionStrategy utilityFunction,
                            ModeAttributesCalculator modeAttributesCalculator){

        // sort by Euclidean distance
        tripTour.sortTripsByDistance();

        // initialise the first mode with walk, so it does not catch the if condition just below
        TransportMode firstMode = TransportMode.WALK;

        // go through the trips
        for (Trip trip : tripTour.getTripChain()) {
            String departurePostcode = trip.getDepartureActivity().getLocation().getPostcode();
            String arrivalPostcode = trip.getArrivalActivity().getLocation().getPostcode();
            TwoStringKeys symmetricPostcodes = new TwoStringKeys(departurePostcode, arrivalPostcode);
            // if the first mode was the car driver, the whole chain is by that mode
            if (tripTour.getTripChain().indexOf(trip) != 0 && firstMode.equals(TransportMode.CAR_DRIVER)) {
                trip.setTransportMode(TransportMode.CAR_DRIVER);

                double distance = routingSymmetric.getCarDistance(symmetricPostcodes);
                trip.setDistance(distance);

                beliefContext.getModeOfTransportTracker().notifyTransportModeUsed(
                        TransportMode.CAR_DRIVER,
                        beliefContext.getToday(),
                        trip.getArrivalActivity().getActivityType(),
                        person.hasCarLicense(),
                        person.getHousehold().hasCarOwnership(),
                        trip.getBeelineDistance(),
                        person.getHousehold().getIncomeThird(),
                        departurePostcode,
                        arrivalPostcode
                );
            } else {
                // either first trip of the chain, either the car driver was not chosen as first mode

                ModeAttributes modeAttributes = modeAttributesCalculator.calculateModeAttributes(trip,
                        routingSymmetric,
                        routingBus,
                        routingTrain,
                        utilityFunction,
                        person,
                        tripTour.getTripChain().indexOf(trip) == 0);
                //Ensure that one mode is possible before attempting to assign a probability.
                if (!modeAttributes.isEmpty()) {
                    // compute choice probabilities
                    Map<TransportMode, Double> choiceProbabilities = utilityFunction.calculateUtilities(
                            modeAttributes,
                            person,
                            trip
                    );

                    // decide the modal choice
                    TransportMode transportMode = CumulativeDistribution.sampleWithCumulativeDistribution(NormaliseProbability.normaliseUtilities(choiceProbabilities), _random);
                    trip.setTransportMode(transportMode);

                    double distance = 0;
                    if (transportMode.equals(TransportMode.WALK)
                            || transportMode.equals(TransportMode.BIKE)
                            || transportMode.equals(TransportMode.CAR_PASSENGER)
                            || transportMode.equals(TransportMode.CAR_DRIVER)) {
                        distance = modeAttributes.getDistance(transportMode);
                    } else if (transportMode.equals(TransportMode.BUS_TRAM)) {
                        distance = routingBus.getTotalDistance(departurePostcode, arrivalPostcode);
                    } else {
                        distance = routingTrain.getTotalDistance(departurePostcode, arrivalPostcode);
                    }
                    trip.setDistance(distance);

                    beliefContext.getModeOfTransportTracker().notifyTransportModeUsed(
                            transportMode,
                            beliefContext.getToday(),
                            trip.getArrivalActivity().getActivityType(),
                            person.hasCarLicense(),
                            person.getHousehold().hasCarOwnership(),
                            trip.getDistance(),
                            person.getHousehold().getIncomeThird(),
                            arrivalPostcode,
                            departurePostcode
                    );

                    if (tripTour.getTripChain().indexOf(trip) == 0) {
                        firstMode = transportMode;
                    }
                }
            }

        }
    }
}
