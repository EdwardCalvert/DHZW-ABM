package main.java.nl.uu.iss.ga.util;

import main.java.nl.uu.iss.ga.model.data.dictionary.TransportMode;

import java.util.Map;

public class NormaliseProbability {

    public static Map<TransportMode, Double> normaliseUtilities(Map<TransportMode, Double> choiceProbabilities){
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
