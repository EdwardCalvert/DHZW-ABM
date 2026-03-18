package main.java.nl.uu.iss.ga.simulation.utilityfunctions;

import main.java.nl.uu.iss.ga.model.data.Household;
import main.java.nl.uu.iss.ga.model.data.Person;
import main.java.nl.uu.iss.ga.model.data.SttParameterSet;
import main.java.nl.uu.iss.ga.model.data.Trip;
import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import main.java.nl.uu.iss.ga.model.interfaces.IUtilityFunctionStrategy;
import nl.uu.cs.iss.ga.sim2apl.core.agent.Context;

import java.util.*;


public class SttStrategy implements IUtilityFunctionStrategy, Context {
    private final SttParameterSet p;

    public SttStrategy(SttParameterSet paramSet) {
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
            Household household,
            Trip trip) {


        // probability distribution of transport modes
        HashMap<TransportMode, Double> choiceProbabilities = new HashMap<>();

        if (walkPossible) {
            choiceProbabilities.put(TransportMode.WALK,
                    p.alphaWalk()
                            + p.betaTimeWalk() * travelTimes.get(TransportMode.WALK));
        }
        if (bikePossible) {
            choiceProbabilities.put(TransportMode.BIKE,
                    p.alphaBike()
                            + p.betaTimeBike() * travelTimes.get(TransportMode.BIKE));
        }
        if (carDriverPossible) {
            choiceProbabilities.put(TransportMode.CAR_DRIVER,
                    p.alphaCarDriver()
                            + p.betaTimeCarDriver() * travelTimes.get(TransportMode.CAR_DRIVER)
                            + p.betaCostCarDriver() * p.carCostKm() * travelDistances.get(TransportMode.CAR_DRIVER));
        }
        if (carPassengerPossible) {
            choiceProbabilities.put(TransportMode.CAR_PASSENGER,
                    p.alphaCarPassenger()
                            + p.betaTimeCarPassenger() * travelTimes.get(TransportMode.CAR_PASSENGER)
                            + p.betaCostCarPassenger() * p.carCostKm() * travelDistances.get(TransportMode.CAR_PASSENGER));
        }

        if (trainPossible) {
            choiceProbabilities.put(TransportMode.TRAIN,
                    p.alphaTrain()
                            + p.betaTimeTrain() * travelTimes.get(TransportMode.TRAIN)
                            + p.betaCostTrain() * (p.ptCostKm() * travelDistances.get(TransportMode.TRAIN) + p.ptBaseCost())
                            + p.betaTimeBus() * busTimeTrain
                            + p.betaCostBus() * (p.ptCostKm() * busDistanceTrain + p.ptBaseCost())
                            + p.betaTimeWalkTransport() * walkTimeTrain
                            + p.betaChangesTransport() * nChangesTrain);
        }

        if (busTramPossible) {
            choiceProbabilities.put(TransportMode.BUS_TRAM,
                    p.alphaBus()
                            + p.betaTimeBus() * travelTimes.get(TransportMode.BUS_TRAM)
                            + p.betaCostBus() * (p.ptCostKm() * travelDistances.get(TransportMode.BUS_TRAM) + p.ptBaseCost())
                            + p.betaTimeWalkTransport() * walkTimeBus
                            + p.betaChangesTransport() * nChangesBus);
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
}
