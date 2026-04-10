package main.java.nl.uu.iss.ga.simulation.utilityfunctions;

import main.java.nl.uu.iss.ga.model.data.*;
import main.java.nl.uu.iss.ga.model.reader.ParameterReader;
import nl.uu.cs.iss.ga.sim2apl.core.agent.Context;

/**
 * This is a wrapper to encapsulate all configuration of the util class instantiation
 * Required since getContext(IUtilityFunctionStrategy.class) doesn't return an object
 */
public class UtilFunctionProvider implements Context {
    private IUtilityFunctionStrategy utilityFunctionStrategy;
    public UtilFunctionProvider(String parameterFilePath, int parameterSetIndex,String functionChoice ){
        if(functionChoice.equals("stt")){
            utilityFunctionStrategy = new SttStrategy(new SttParameterSet(new ParameterReader(parameterFilePath, parameterSetIndex)));
        }
        else if(functionChoice.equals("vot")){
            utilityFunctionStrategy = new VotStrategy(new VotParameterSet(new ParameterReader(parameterFilePath, parameterSetIndex)));
        }
        else if(functionChoice.equals("stt-unified")){
            utilityFunctionStrategy = new SttUnifiedCostStrategy(new SttUnifiedCostParameterSet(new ParameterReader(parameterFilePath, parameterSetIndex)));
        }
        else{
            throw new IllegalArgumentException("The utility function provided could not be understood: " + functionChoice);
        }

    }
    public IUtilityFunctionStrategy getUtilityFunction(){
        return this.utilityFunctionStrategy;
    }

}
