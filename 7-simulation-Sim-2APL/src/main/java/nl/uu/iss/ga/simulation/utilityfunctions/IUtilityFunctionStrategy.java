package main.java.nl.uu.iss.ga.simulation.utilityfunctions;

import main.java.nl.uu.iss.ga.model.data.Person;
import main.java.nl.uu.iss.ga.model.data.Trip;
import main.java.nl.uu.iss.ga.model.data.dictionary.ModeAttributes;
import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;
import nl.uu.cs.iss.ga.sim2apl.core.agent.Context;

import java.util.Map;

public interface IUtilityFunctionStrategy extends Context {
    public Map<TransportMode, Double> calculateUtilities(
            ModeAttributes modeAttributes,
            Person person,
            Trip trip) ;
    public boolean isMaxDistanceLimit();
}
