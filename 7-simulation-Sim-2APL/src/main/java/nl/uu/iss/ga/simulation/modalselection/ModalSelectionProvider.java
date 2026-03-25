package main.java.nl.uu.iss.ga.simulation.modalselection;

import nl.uu.cs.iss.ga.sim2apl.core.agent.Context;

import java.util.Random;

public class ModalSelectionProvider implements Context {

    private IModalSelectionStrategy selectionStrategy;

    public ModalSelectionProvider(String strategy, Random random){
        if(strategy.equals("aggregate")){
            selectionStrategy = new AggregateModalSelectionStrategy(random );
        }
        else if(strategy.equals("sequential")){
            selectionStrategy = new SequentialModalSelectionStrategy(random);
        }
        else{
            throw new  IllegalArgumentException("The modal selection strategy provided could not be understood: " + selectionStrategy);
        }
    }
    public IModalSelectionStrategy getModalChoiceStrategy(){
        return this.selectionStrategy;
    }
}
