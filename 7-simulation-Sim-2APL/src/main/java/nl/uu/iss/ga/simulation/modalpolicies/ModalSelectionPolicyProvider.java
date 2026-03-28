package main.java.nl.uu.iss.ga.simulation.modalpolicies;

import nl.uu.cs.iss.ga.sim2apl.core.agent.Context;

import java.util.Random;

public class ModalSelectionPolicyProvider implements Context {

    private IModalSelectionPolicy selectionPolicy;

    public ModalSelectionPolicyProvider(String strategy, Random random){
        if(strategy.equals("aggregate")){
            selectionPolicy = new AggregateModalSelectionPolicy(random );
        }
        else if(strategy.equals("sequential")){
            selectionPolicy = new SequentialModalSelectionPolicy(random);
        }
        else{
            throw new  IllegalArgumentException("The modal selection strategy provided could not be understood: " + selectionPolicy);
        }
    }
    public IModalSelectionPolicy getModalChoiceStrategy(){
        return this.selectionPolicy;
    }
}
