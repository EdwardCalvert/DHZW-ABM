package main.java.nl.uu.iss.ga.simulation.modalselection;

import main.java.nl.uu.iss.ga.model.data.Person;
import main.java.nl.uu.iss.ga.model.data.Trip;
import main.java.nl.uu.iss.ga.model.data.dictionary.ModeAttributes;
import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import main.java.nl.uu.iss.ga.model.data.dictionary.TwoStringKeys;
import main.java.nl.uu.iss.ga.simulation.agent.context.RoutingBusBeliefContext;
import main.java.nl.uu.iss.ga.simulation.agent.context.RoutingSimmetricBeliefContext;
import main.java.nl.uu.iss.ga.simulation.agent.context.RoutingTrainBeliefContext;
import main.java.nl.uu.iss.ga.simulation.utilityfunctions.IUtilityFunctionStrategy;

public class ModeAttributesCalculator {

    public ModeAttributes calculateModeAttributes(Trip trip,
                                                   RoutingSimmetricBeliefContext routingSymmetric,
                                                   RoutingBusBeliefContext routingBus,
                                                   RoutingTrainBeliefContext routingTrain,
                                                   IUtilityFunctionStrategy utilityFunction,
                                                   Person person,
                                                  boolean carEnabled) {
        String departurePostcode = trip.getDepartureActivity().getLocation().getPostcode();
        String arrivalPostcode = trip.getArrivalActivity().getLocation().getPostcode();
        boolean departureInDHZW = trip.getDepartureActivity().getLocation().isInDHZW();
        boolean arrivalInDHZW = trip.getArrivalActivity().getLocation().isInDHZW();

        ModeAttributes modeAtributes = new ModeAttributes();

        TwoStringKeys symmetricPostcodes = new TwoStringKeys(departurePostcode, arrivalPostcode);
        if (routingSymmetric.getWalkTime(symmetricPostcodes) != -1.0
                && (routingSymmetric.getWalkDistance(symmetricPostcodes) < 5.0) || !utilityFunction.isMaxDistanceLimit()) {
            modeAtributes.setTime(TransportMode.WALK, routingSymmetric.getWalkTime(symmetricPostcodes));
            modeAtributes.setDistance(TransportMode.WALK, routingSymmetric.getWalkDistance(symmetricPostcodes));
        }
        if (routingSymmetric.getBikeTime(symmetricPostcodes) != -1.0
                && (routingSymmetric.getBikeDistance(symmetricPostcodes) < 15.0 || !utilityFunction.isMaxDistanceLimit())) {
            modeAtributes.setTime(TransportMode.BIKE, routingSymmetric.getBikeTime(symmetricPostcodes));
            modeAtributes.setDistance(TransportMode.BIKE, routingSymmetric.getWalkDistance(symmetricPostcodes));
        }
        // if trip is feasible by car and the household has a car, the agent can be passenger
        if (routingSymmetric.getCarDistance(symmetricPostcodes) != -1.0 && person.getHousehold().hasCarOwnership()) {
            modeAtributes.setTime(TransportMode.CAR_PASSENGER, routingSymmetric.getCarTime(symmetricPostcodes));
            modeAtributes.setDistance(TransportMode.CAR_PASSENGER, routingSymmetric.getCarDistance(symmetricPostcodes));
        }
        // car is either chosen at the beginning or never anymore. If it is taken at the first round, it is automatically applied to all the other trips.
        if  (carEnabled
                && person.getAge() >= 18
                && person.getHousehold().hasCarOwnership()
                && routingSymmetric.getCarTime(symmetricPostcodes) != -1.0) {
            modeAtributes.setTime(TransportMode.CAR_DRIVER, routingSymmetric.getCarTime(symmetricPostcodes));
            modeAtributes.setDistance(TransportMode.CAR_DRIVER, routingSymmetric.getCarDistance(symmetricPostcodes));
        }

        if (routingBus.getFeasibleFlag(departurePostcode, arrivalPostcode) != -1) {
            modeAtributes.setTime(TransportMode.BUS_TRAM, routingBus.getBusTime(departurePostcode, arrivalPostcode));
            modeAtributes.setDistance(TransportMode.BUS_TRAM, routingBus.getBusDistance(departurePostcode, arrivalPostcode));
            modeAtributes.nChangesBus = routingBus.getChange(departurePostcode, arrivalPostcode);
            modeAtributes.walkTimeBus = routingBus.getWalkTime(departurePostcode, arrivalPostcode);
        }

        // if the trip is partially outside, the train could be possible
        if (departureInDHZW ^ arrivalInDHZW && routingTrain.getFeasibleFlag(departurePostcode, arrivalPostcode) != -1) {
            modeAtributes.setTime(TransportMode.TRAIN, routingTrain.getTrainTime(departurePostcode, arrivalPostcode));
            modeAtributes.setDistance(TransportMode.TRAIN, routingTrain.getTrainDistance(departurePostcode, arrivalPostcode));
            modeAtributes.nChangesTrain = routingTrain.getChange(departurePostcode, arrivalPostcode);
            modeAtributes.walkTimeTrain = routingTrain.getWalkTime(departurePostcode, arrivalPostcode);
            modeAtributes.busTimeTrain = routingTrain.getBusTime(departurePostcode, arrivalPostcode);
            modeAtributes.busDistanceTrain = routingTrain.getBusDistance(departurePostcode, arrivalPostcode);
        }
        return modeAtributes;
    }
}
