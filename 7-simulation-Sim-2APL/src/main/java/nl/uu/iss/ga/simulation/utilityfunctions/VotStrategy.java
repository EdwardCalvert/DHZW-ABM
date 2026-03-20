package main.java.nl.uu.iss.ga.simulation.utilityfunctions;

import main.java.nl.uu.iss.ga.model.data.Household;
import main.java.nl.uu.iss.ga.model.data.Person;
import main.java.nl.uu.iss.ga.model.data.Trip;
import main.java.nl.uu.iss.ga.model.data.VotParameterSet;
import main.java.nl.uu.iss.ga.model.data.dictionary.ModeAttributes;
import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import main.java.nl.uu.iss.ga.model.data.dictionary.TripPurpose;
import main.java.nl.uu.iss.ga.model.reader.MNLparametersReader;
import nl.uu.cs.iss.ga.sim2apl.core.agent.Context;

import java.util.HashMap;
import java.util.logging.Logger;

public class VotStrategy implements IUtilityFunctionStrategy, Context {
    private static final Logger LOGGER = Logger.getLogger(MNLparametersReader.class.getName());
    private final VotParameterSet p;

    public VotStrategy(VotParameterSet paramSet) {
        this.p = paramSet;
    }

    public HashMap<TransportMode, Double> calculateUtilities(
            ModeAttributes m,
            Person person,
            Trip trip) {
        TripPurpose tripPurpose = trip.getTripPurpose();

        Household h = person.getHousehold();

        // probability distribution of transport modes
        HashMap<TransportMode, Double> modeUtilities = new HashMap<>();

        if (m.modePresent(TransportMode.WALK)) {
            modeUtilities.put(TransportMode.WALK,
                    p.alphaWalk
                            + p.betaCost(h.getIncomeThird())
                            * (p.vot(TransportMode.WALK, tripPurpose) * (m.getDistance(TransportMode.WALK))/60)
            );
        }
        if (m.modePresent(TransportMode.BIKE) ) {
            modeUtilities.put(TransportMode.BIKE,
                    p.alphaBike
                            + p.betaCost(h.getIncomeThird())
                            * (p.vot(TransportMode.BIKE, tripPurpose) * (m.getDistance(TransportMode.BIKE))/60)
            );
        }
        if (m.modePresent(TransportMode.CAR_DRIVER)) {
            modeUtilities.put(TransportMode.CAR_DRIVER, p.alphaCarDriver
                    + p.betaCost(h.getIncomeThird())
                    * (p.carCostKm * m.getDistance(TransportMode.CAR_DRIVER)
                    + p.vot(TransportMode.CAR_DRIVER, tripPurpose) + (m.getDistance(TransportMode.CAR_DRIVER)/60)));
        }
        if (m.modePresent(TransportMode.CAR_PASSENGER) ) {
            modeUtilities.put(TransportMode.CAR_PASSENGER,-100.0);
        }

        if (m.modePresent(TransportMode.TRAIN)) {
            modeUtilities.put(TransportMode.TRAIN,
                    p.alphaTrain
                            + p.betaCost(h.getIncomeThird())
                            * (
                            (p.ptCostKm * m.getDistance(TransportMode.TRAIN) + p.ptBaseCost)
                                    + p.vot(TransportMode.TRAIN, tripPurpose) * (m.getTime(TransportMode.TRAIN)/60)
                                    + p.vot(TransportMode.BUS_TRAM, tripPurpose) * p.weightAccessEgress * (m.busTimeTrain/60)
                                    + (p.ptCostKm * m.busDistanceTrain + p.ptBaseCost)
                                    + p.vot(TransportMode.WALK, tripPurpose) * p.weightAccessEgress * (m.walkTimeTrain/60)
                    )
                            + p.betaChangesTransport * m.nChangesTrain);

        }

        if (m.modePresent(TransportMode.BUS_TRAM) ) {
            modeUtilities.put(TransportMode.BUS_TRAM,
                    p.alphaBus
                            + p.betaCost(h.getIncomeThird())
                            * (
                                (p.ptCostKm * m.getDistance(TransportMode.BUS_TRAM) + p.ptBaseCost)
                                + p.vot(TransportMode.BUS_TRAM, tripPurpose) * (m.getTime(TransportMode.BUS_TRAM)/60)
                                + p.vot(TransportMode.BUS_TRAM, tripPurpose) * p.weightAccessEgress * (m.walkTimeBus/60)
                    )
                            + p.betaChangesTransport * m.nChangesBus);
        }

        // exponential of each utility
        return modeUtilities;
    }


    public boolean isMaxDistanceLimit() {
        return true;
    }
}
