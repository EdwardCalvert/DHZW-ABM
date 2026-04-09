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

import java.util.*;

public class AggregateModalSelectionPolicy implements IModalSelectionPolicy {
    private final Random _random;

    public AggregateModalSelectionPolicy(Random random) {
        this._random = random;
    }

    public void assignModes(TripTour tripTour,
                            Person person,
                            BeliefContext beliefContext,
                            RoutingSimmetricBeliefContext routingSymmetric,
                            RoutingBusBeliefContext routingBus,
                            RoutingTrainBeliefContext routingTrain,
                            IUtilityFunctionStrategy utilityFunction,
                            ModeAttributesCalculator modeAttributesCalculator) {

        List<Map<TransportMode, Double>> modalUtilities = new ArrayList<>(tripTour.getTripChain().size());
        List<ModeAttributes> modeAttributesArray = new ArrayList<>(tripTour.getTripChain().size());

        // go through the trips, and calculate the utility of all applicable modes for that trip
        for (int i = 0; i < tripTour.getTripChain().size(); i++) {
            Trip trip = tripTour.getTripChain().get(i);
            ModeAttributes modeAttributes = modeAttributesCalculator.calculateModeAttributes(trip,
                    routingSymmetric,
                    routingBus,
                    routingTrain,
                    utilityFunction,
                    person,
                    true,
                    utilityFunction.carStartsHome());
            modeAttributesArray.add(modeAttributes);

            //Ensure that one mode is possible before attempting to assign a probability.
            if (!modeAttributes.isEmpty()) {
                // compute choice probabilities
                modalUtilities.add(utilityFunction.calculateUtilities(
                        modeAttributes,
                        person,
                        trip
                ));
            }
        }
        if(modalUtilities.isEmpty()){
            return;
        }

        Map<TransportMode, Double> reducedModalUtilities = aggregateUtilities(modalUtilities);

        TransportMode overallModeSelection = CumulativeDistribution.sampleWithCumulativeDistribution(NormaliseProbability.normaliseUtilities(reducedModalUtilities), _random);
        if (overallModeSelection == TransportMode.BIKE || overallModeSelection == TransportMode.CAR_DRIVER) {
            for (int j = 0; j < tripTour.getTripChain().size(); j++) {
                Trip trip = tripTour.getTripChain().get(j);
                String departurePostcode = trip.getDepartureActivity().getLocation().getPostcode();
                String arrivalPostcode = trip.getArrivalActivity().getLocation().getPostcode();

                TwoStringKeys symmetricPostcodes = new TwoStringKeys(departurePostcode, arrivalPostcode);
                double distance;
                if (overallModeSelection == TransportMode.BIKE) {
                    distance = routingSymmetric.getBikeDistance(symmetricPostcodes);
                } else {
                    distance = routingSymmetric.getCarDistance(symmetricPostcodes);
                }

                trip.setDistance(distance);

                trip.setTransportMode(overallModeSelection);
                beliefContext.getModeOfTransportTracker().notifyTransportModeUsed(
                        overallModeSelection,
                        beliefContext.getToday(),
                        trip.getArrivalActivity().getActivityType(),
                        person.hasCarLicense(),
                        person.getHousehold().hasCarOwnership(),
                        trip.getDistance(),
                        person.getHousehold().getIncomeThird(),
                        departurePostcode,
                        arrivalPostcode
                );

            }
        } else {

            //Remove bike and car choices
            int l = 0;
            while(l < modalUtilities.size()){
                if(modalUtilities.get(l).size() <= 1 && (modalUtilities.get(l).containsKey(TransportMode.BIKE) || modalUtilities.get(l).containsKey(TransportMode.CAR_DRIVER))){
                    //In my testing, this was never called, but I thought I should include for the sanity of the next guy!
                    throw new RuntimeException("THIS TOUR IS NOT POSSIBLE!");
                }
                //Remove options
                modalUtilities.get(l).remove(TransportMode.CAR_DRIVER);
                modalUtilities.get(l).remove(TransportMode.BIKE);
                l++;
            }

            for (int k = 0; k < tripTour.getTripChain().size(); k++) {
                Trip trip = tripTour.getTripChain().get(k);
                String departurePostcode = trip.getDepartureActivity().getLocation().getPostcode();
                String arrivalPostcode = trip.getArrivalActivity().getLocation().getPostcode();
                TwoStringKeys symmetricPostcodes = new TwoStringKeys(departurePostcode, arrivalPostcode);

                TransportMode transportMode = CumulativeDistribution.sampleWithCumulativeDistribution(NormaliseProbability.normaliseUtilities( modalUtilities.get(k)), _random);
                if( transportMode.equals(TransportMode.BIKE) || transportMode.equals(TransportMode.CAR_DRIVER)){
                    throw new RuntimeException("WHY IS BIKE HERE!");
                }
                double distance = 0;
                if (transportMode.equals(TransportMode.WALK) || transportMode.equals(TransportMode.CAR_PASSENGER)) {
                    distance = modeAttributesArray.get(k).getDistance(transportMode);
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
                        departurePostcode,
                        arrivalPostcode
                );
            }
        }


    }

    /**
     *  Aggregate a list of modal utitlities to a mapping of mode to utility.
     * @param modalUtilities
     * @return
     */
    private Map<TransportMode, Double> aggregateUtilities(List<Map<TransportMode, Double>> modalUtilities){
        Map<TransportMode, Double> reducedModalUtilities = new HashMap<>();


        for (Map<TransportMode, Double> item : modalUtilities) {
            for (Map.Entry<TransportMode, Double> modalUtility : item.entrySet()) {
                if (reducedModalUtilities.containsKey(modalUtility.getKey())) {
                    Double value = reducedModalUtilities.get(modalUtility.getKey()) + modalUtility.getValue();
                    reducedModalUtilities.put(modalUtility.getKey(), value);
                } else {
                    reducedModalUtilities.put(modalUtility.getKey(), modalUtility.getValue());
                }
            }
        }
        return reducedModalUtilities;
    }

}
