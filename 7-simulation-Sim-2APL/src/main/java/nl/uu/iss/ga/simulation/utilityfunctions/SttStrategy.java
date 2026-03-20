package main.java.nl.uu.iss.ga.simulation.utilityfunctions;

import main.java.nl.uu.iss.ga.model.data.Person;
import main.java.nl.uu.iss.ga.model.data.SttParameterSet;
import main.java.nl.uu.iss.ga.model.data.Trip;
import main.java.nl.uu.iss.ga.model.data.dictionary.ModeAttributes;
import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import nl.uu.cs.iss.ga.sim2apl.core.agent.Context;

import java.util.*;


public class SttStrategy implements IUtilityFunctionStrategy, Context {
    private final SttParameterSet p;

    public SttStrategy(SttParameterSet paramSet) {
        this.p = paramSet;
    }

    public HashMap<TransportMode, Double> calculateUtilities(
            ModeAttributes m,
            Person person,
            Trip trip) {

        HashMap<TransportMode, Double> modeUtilities = new HashMap<>();

        if (m.modePresent(TransportMode.WALK)) {
            modeUtilities.put(TransportMode.WALK,
                    p.alphaWalk()
                            + p.betaTimeWalk() * m.getTime(TransportMode.WALK));
        }
        if (m.modePresent(TransportMode.BIKE)) {
            modeUtilities.put(TransportMode.BIKE,
                    p.alphaBike()
                            + p.betaTimeBike() * m.getTime(TransportMode.BIKE));
        }
        if (m.modePresent(TransportMode.BIKE) ) {
            modeUtilities.put(TransportMode.CAR_DRIVER,
                    p.alphaCarDriver()
                            + p.betaTimeCarDriver() * m.getTime(TransportMode.CAR_DRIVER)
                            + p.betaCostCarDriver() * p.carCostKm() * m.getDistance(TransportMode.CAR_DRIVER));
        }
        if (m.modePresent(TransportMode.CAR_PASSENGER) ) {
            modeUtilities.put(TransportMode.CAR_PASSENGER,
                    p.alphaCarPassenger()
                            + p.betaTimeCarPassenger() * m.getTime(TransportMode.CAR_PASSENGER)
                            + p.betaCostCarPassenger() * p.carCostKm() * m.getDistance(TransportMode.CAR_PASSENGER));
        }

        if (m.modePresent(TransportMode.TRAIN)) {
            modeUtilities.put(TransportMode.TRAIN,
                    p.alphaTrain()
                            + p.betaTimeTrain() * m.getTime(TransportMode.TRAIN)
                            + p.betaCostTrain() * (p.ptCostKm() * m.getDistance(TransportMode.TRAIN) + p.ptBaseCost())
                            + p.betaTimeBus() * m.busTimeTrain
                            + p.betaCostBus() * (p.ptCostKm() * m.busDistanceTrain + p.ptBaseCost())
                            + p.betaTimeWalkTransport() * m.walkTimeTrain
                            + p.betaChangesTransport() * m.nChangesTrain);
        }

        if (m.modePresent(TransportMode.BUS_TRAM) ) {
            modeUtilities.put(TransportMode.BUS_TRAM,
                    p.alphaBus()
                            + p.betaTimeBus() * m.getTime(TransportMode.BUS_TRAM)
                            + p.betaCostBus() * (p.ptCostKm() * m.getDistance(TransportMode.BUS_TRAM) + p.ptBaseCost())
                            + p.betaTimeWalkTransport() * m.walkTimeBus
                            + p.betaChangesTransport() * m.nChangesBus);
        }

        return modeUtilities;
    }
    public  boolean isMaxDistanceLimit(){
        return false;
    }
}
