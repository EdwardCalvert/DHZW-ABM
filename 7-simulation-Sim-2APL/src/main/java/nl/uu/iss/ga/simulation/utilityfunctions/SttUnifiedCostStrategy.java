package main.java.nl.uu.iss.ga.simulation.utilityfunctions;

import main.java.nl.uu.iss.ga.model.data.*;
import main.java.nl.uu.iss.ga.model.data.dictionary.ModeAttributes;
import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import nl.uu.cs.iss.ga.sim2apl.core.agent.Context;

import java.util.HashMap;


public class SttUnifiedCostStrategy implements IUtilityFunctionStrategy, Context {
    private final SttUnifiedCostParameterSet p;

    public SttUnifiedCostStrategy(SttUnifiedCostParameterSet paramSet) {
        this.p = paramSet;
    }

    public HashMap<TransportMode, Double> calculateUtilities(
            ModeAttributes m,
            Person person,
            Trip trip) {

        Household h = person.getHousehold();

        HashMap<TransportMode, Double> modeUtilities = new HashMap<>();

        if (m.modePresent(TransportMode.WALK)) {
            modeUtilities.put(TransportMode.WALK,
                    p.alphaWalk()
                            + p.betaTime(TransportMode.WALK, trip.getTripPurpose()) * m.getTime(TransportMode.WALK));
        }
        if (m.modePresent(TransportMode.BIKE)) {
            modeUtilities.put(TransportMode.BIKE,
                    p.alphaBike()
                            + p.betaTime(TransportMode.BIKE, trip.getTripPurpose()) * m.getTime(TransportMode.BIKE));
        }
        if (m.modePresent(TransportMode.CAR_DRIVER) ) {
            modeUtilities.put(TransportMode.CAR_DRIVER,
                    p.alphaCarDriver()
                            + p.betaTime(TransportMode.CAR_DRIVER, trip.getTripPurpose()) * m.getTime(TransportMode.CAR_DRIVER)
                            + p.betaCost(h.getIncomeThird()) * p.carCostKm() * m.getDistance(TransportMode.CAR_DRIVER));
        }
        if (m.modePresent(TransportMode.CAR_PASSENGER) ) {
            modeUtilities.put(TransportMode.CAR_PASSENGER,
                    p.alphaCarPassenger()
                            + p.betaTime(TransportMode.CAR_PASSENGER, trip.getTripPurpose()) * m.getTime(TransportMode.CAR_PASSENGER)
                            + p.betaCost(h.getIncomeThird()) * p.carCostKm() * m.getDistance(TransportMode.CAR_PASSENGER));
        }

        if (m.modePresent(TransportMode.TRAIN)) {
            modeUtilities.put(TransportMode.TRAIN,
                    p.alphaTrain()
                            + p.betaTime(TransportMode.TRAIN, trip.getTripPurpose()) * m.getTime(TransportMode.TRAIN)
                            + p.betaCost(h.getIncomeThird()) * (p.ptCostKm() * m.getDistance(TransportMode.TRAIN) + p.ptBaseCost())
                            + p.betaTime(TransportMode.BUS_TRAM, trip.getTripPurpose()) * m.busTimeTrain
                            + p.betaCost(h.getIncomeThird()) * (p.ptCostKm() * m.busDistanceTrain + p.ptBaseCost())
                            + p.betaTimeWalkTransport() * m.walkTimeTrain
                            + p.betaChangesTransport() * m.nChangesTrain);
        }

        if (m.modePresent(TransportMode.BUS_TRAM) ) {
            modeUtilities.put(TransportMode.BUS_TRAM,
                    p.alphaBus()
                            + p.betaTime(TransportMode.BUS_TRAM, trip.getTripPurpose()) * m.getTime(TransportMode.BUS_TRAM)
                            + p.betaCost(h.getIncomeThird()) * (p.ptCostKm() * m.getDistance(TransportMode.BUS_TRAM) + p.ptBaseCost())
                            + p.betaTimeWalkTransport() * m.walkTimeBus
                            + p.betaChangesTransport() * m.nChangesBus);
        }

        return modeUtilities;
    }
    public  boolean isMaxDistanceLimit(){
        return true;
    }
    public boolean carStartsHome(){return  false;}//Assume car just travels the minimum distance
}
