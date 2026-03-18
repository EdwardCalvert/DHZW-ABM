package main.java.nl.uu.iss.ga.simulation.utilityfunctions;

import main.java.nl.uu.iss.ga.model.data.Household;
import main.java.nl.uu.iss.ga.model.data.Person;
import main.java.nl.uu.iss.ga.model.data.Trip;
import main.java.nl.uu.iss.ga.model.data.VotParameterSet;
import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import main.java.nl.uu.iss.ga.model.data.dictionary.TripPurpose;
import main.java.nl.uu.iss.ga.model.interfaces.IUtilityFunctionStrategy;
import nl.uu.cs.iss.ga.sim2apl.core.agent.Context;

import java.util.HashMap;
import java.util.Map;

public class VotStrategy implements IUtilityFunctionStrategy, Context {
    private final VotParameterSet p;

    public VotStrategy(VotParameterSet paramSet) {
        this.p = paramSet;
    }

    public HashMap<TransportMode, Double> getChoiceProbabilities(
            boolean walkPossible,
            boolean bikePossible,
            boolean carDriverPossible,
            boolean carPassengerPossible,
            boolean busTramPossible,
            boolean trainPossible,
            Map<TransportMode, Double> travelTimes,
            Map<TransportMode, Double> travelDistances,
            double walkTimeBus,
            int nChangesBus,
            double walkTimeTrain,
            double busTimeTrain,
            double busDistanceTrain,
            int nChangesTrain,
            Person person,
            Household h,
            Trip trip) {
        TripPurpose tripPurpose = trip.getTripPurpose();

        // probability distribution of transport modes
        HashMap<TransportMode, Double> choiceProbabilities = new HashMap<>();

        if (walkPossible) {
            choiceProbabilities.put(TransportMode.WALK,
                    p.alphaWalk
                            + p.betaCost(h.getIncomeThird())
                            * (p.vot(TransportMode.WALK, tripPurpose) * travelTimes.get(TransportMode.WALK))
            );
        }
        if (bikePossible) {
            choiceProbabilities.put(TransportMode.BIKE,
                    p.alphaBike
                            + p.betaCost(h.getIncomeThird())
                            * (p.vot(TransportMode.BIKE, tripPurpose) * travelTimes.get(TransportMode.BIKE))
            );
        }
        if (carDriverPossible) {
            choiceProbabilities.put(TransportMode.CAR_DRIVER, carUtility(travelTimes, travelDistances, h, tripPurpose));
        }
        if (carPassengerPossible) {
            choiceProbabilities.put(TransportMode.CAR_PASSENGER, carUtility(travelTimes, travelDistances, h, tripPurpose));
        }

        if (trainPossible) {
            choiceProbabilities.put(TransportMode.TRAIN,
                    p.alphaTrain
                            + p.betaCost(h.getIncomeThird())
                            * (
                            (p.ptCostKm * travelDistances.get(TransportMode.TRAIN) + p.ptBaseCost)
                                    + p.vot(TransportMode.TRAIN, tripPurpose) * travelTimes.get(TransportMode.TRAIN)
                                    + p.vot(TransportMode.TRAIN, tripPurpose) * p.weightAccessEgress * busTimeTrain
                                    + (p.ptCostKm * busDistanceTrain + p.ptBaseCost)
                                    + p.vot(TransportMode.TRAIN, tripPurpose) * p.weightAccessEgress * walkTimeTrain
                    )
                            + p.betaChangesTransport * nChangesTrain);
        }

        if (busTramPossible) {
            choiceProbabilities.put(TransportMode.BUS_TRAM,
                    p.alphaBus
                            + p.betaCost(h.getIncomeThird())
                            * (
                                (p.ptCostKm * travelDistances.get(TransportMode.BUS_TRAM) + p.ptBaseCost)
                                + p.vot(TransportMode.BUS_TRAM, tripPurpose) * travelTimes.get(TransportMode.BUS_TRAM)
                                + p.vot(TransportMode.BUS_TRAM, tripPurpose) * p.weightAccessEgress * walkTimeBus
                    )
                            + p.betaChangesTransport * nChangesBus);
        }

        // exponential of each utility
        double sumUtilitiesExp = 0.0;
        for (TransportMode transportMode : choiceProbabilities.keySet()) {
            choiceProbabilities.put(transportMode, Math.exp(choiceProbabilities.get(transportMode)));
            sumUtilitiesExp += choiceProbabilities.get(transportMode);
        }

        // update map by dividing the exponential utilities by their sum
        for (TransportMode transportMode : choiceProbabilities.keySet()) {
            choiceProbabilities.put(transportMode, choiceProbabilities.get(transportMode) / sumUtilitiesExp);
        }
        return choiceProbabilities;
    }

    private double carUtility(Map<TransportMode, Double> travelTimes,
                              Map<TransportMode, Double> travelDistances,
                              Household h,
                              TripPurpose tripPurpose) {
        return p.alphaCarDriver
                + p.betaCost(h.getIncomeThird())
                * (p.carCostKm * travelDistances.get(TransportMode.CAR_DRIVER)
                + p.vot(TransportMode.CAR_DRIVER, tripPurpose) + travelTimes.get(TransportMode.CAR_DRIVER));
    }

}
