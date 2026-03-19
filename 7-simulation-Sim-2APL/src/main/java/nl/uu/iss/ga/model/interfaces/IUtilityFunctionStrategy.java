package main.java.nl.uu.iss.ga.model.interfaces;

import main.java.nl.uu.iss.ga.model.data.Household;
import main.java.nl.uu.iss.ga.model.data.Person;
import main.java.nl.uu.iss.ga.model.data.Trip;
import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import nl.uu.cs.iss.ga.sim2apl.core.agent.Context;

import java.util.Map;

public interface IUtilityFunctionStrategy extends Context {
    public Map<TransportMode, Double> getChoiceProbabilities (
            boolean walkPossible,
            boolean bikePossible,
            boolean carDriverPossible,
            boolean carPassengerPossible,
            boolean busTramPossible,
            boolean trainPossible,
            Map<TransportMode, Double> travelTimes,
            Map<TransportMode,Double> travelDistances,
            double walkTimeBus,
            int nChangesBus,
            double walkTimeTrain,
            double busTimeTrain,
            double busDistanceTrain,
            int nChangesTrain,
            Person person,
            Trip trip) ;
}
