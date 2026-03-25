package main.java.nl.uu.iss.ga.simulation.utilityfunctions;

import main.java.nl.uu.iss.ga.model.data.Household;
import main.java.nl.uu.iss.ga.model.data.Person;
import main.java.nl.uu.iss.ga.model.data.Trip;
import main.java.nl.uu.iss.ga.model.data.VotParameterSet;
import main.java.nl.uu.iss.ga.model.data.dictionary.ModeAttributes;
import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import main.java.nl.uu.iss.ga.model.data.dictionary.TripPurpose;
import nl.uu.cs.iss.ga.sim2apl.core.agent.Context;

import java.util.HashMap;
import java.util.logging.Logger;

public class VotStrategy implements IUtilityFunctionStrategy, Context {
    private static final Logger LOGGER = Logger.getLogger(VotStrategy.class.getName());
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
                            * (p.weightVotCosts * p.vot(TransportMode.WALK, tripPurpose) * (m.getDistance(TransportMode.WALK))/60.0)
            );
        }
        if (m.modePresent(TransportMode.BIKE) ) {
            modeUtilities.put(TransportMode.BIKE,
                    p.alphaBike
                            + p.betaCost(h.getIncomeThird())
                            * (p.weightVotCosts * p.vot(TransportMode.BIKE, tripPurpose) * (m.getDistance(TransportMode.BIKE))/60.0)
            );
        }
        if (m.modePresent(TransportMode.CAR_DRIVER)) {
            double monetaryCosts = p.carCostKm * m.getDistance(TransportMode.CAR_DRIVER);
            double weightedTime =  p.vot(TransportMode.CAR_DRIVER, tripPurpose) * (m.getDistance(TransportMode.CAR_DRIVER)/60.0);

            //doubled because we assume the car returns home???
            modeUtilities.put(TransportMode.CAR_DRIVER, p.alphaCarDriver
                    + p.betaCost(h.getIncomeThird()) * (2*(p.weightVotCosts * weightedTime +  p.weightTangibleCosts*  monetaryCosts )));
        }
        if (m.modePresent(TransportMode.CAR_PASSENGER) ) {
            double monetaryCosts = (p.carCostKm * m.getDistance(TransportMode.CAR_PASSENGER));
            double weightedTime = p.vot(TransportMode.CAR_DRIVER, tripPurpose) * (m.getDistance(TransportMode.CAR_PASSENGER)/60.0);
            modeUtilities.put(TransportMode.CAR_PASSENGER, p.alphaCarPassenger
                    + p.betaCost(h.getIncomeThird()) * ( p.weightVotCosts *  weightedTime + p.weightTangibleCosts* monetaryCosts ));
        }

        if (m.modePresent(TransportMode.TRAIN)) {
            double monetaryCosts = (p.ptCostKm * m.busDistanceTrain + p.ptBaseCost)
                                    +(p.ptCostKm * m.getDistance(TransportMode.TRAIN) + p.ptBaseCost);
            double weightedTime = p.vot(TransportMode.TRAIN, tripPurpose) * (m.getTime(TransportMode.TRAIN)/60.0)
                    + p.vot(TransportMode.BUS_TRAM, tripPurpose) * p.weightFeeder * (m.busTimeTrain/60.0)
                    + p.vot(TransportMode.WALK, tripPurpose) * p.weightWalk * (m.walkTimeTrain/60.0)
                    + p.vot(TransportMode.TRAIN, tripPurpose) *p.weightWait* (m.waitTimeTrain/60.0); //Assume waiting time cost proportional to in vehicle time

            modeUtilities.put(TransportMode.TRAIN,
                    p.alphaTrain
                            + p.betaCost(h.getIncomeThird()) * ( p.weightVotCosts* weightedTime + p.weightTangibleCosts * monetaryCosts)
                            + p.betaChangesTransport * m.nChangesTrain);
        }

        if (m.modePresent(TransportMode.BUS_TRAM) ) {
            double monetaryCosts =  (p.ptCostKm * m.getDistance(TransportMode.BUS_TRAM) + p.ptBaseCost);
            double timeCosts =  p.vot(TransportMode.BUS_TRAM, tripPurpose) * (m.getTime(TransportMode.BUS_TRAM)/60.0)
                                 + p.vot(TransportMode.WALK, tripPurpose) * p.weightWalk * (m.walkTimeBus/60.0)
                                + p.vot(TransportMode.BUS_TRAM, tripPurpose) *p.weightWait* (m.waitTimeBus/60.0);


            modeUtilities.put(TransportMode.BUS_TRAM,
                    p.alphaBus
                            + p.betaCost(h.getIncomeThird()) * ( p.weightVotCosts*  timeCosts + p.weightTangibleCosts * monetaryCosts)
                            + p.betaChangesTransport * m.nChangesBus);
        }

        return modeUtilities;
    }


    public boolean isMaxDistanceLimit() {
        return true;
    }
}
