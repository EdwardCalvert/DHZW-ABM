package main.java.nl.uu.iss.ga.simulation.modalpolicies;

import main.java.nl.uu.iss.ga.model.data.Person;
import main.java.nl.uu.iss.ga.model.data.TripTour;
import main.java.nl.uu.iss.ga.simulation.agent.context.BeliefContext;
import main.java.nl.uu.iss.ga.simulation.agent.context.RoutingBusBeliefContext;
import main.java.nl.uu.iss.ga.simulation.agent.context.RoutingSimmetricBeliefContext;
import main.java.nl.uu.iss.ga.simulation.agent.context.RoutingTrainBeliefContext;
import main.java.nl.uu.iss.ga.simulation.utilityfunctions.IUtilityFunctionStrategy;

public interface IModalSelectionPolicy {
    void assignModes(
            TripTour tour,
            Person person,
            BeliefContext beliefContext,
            RoutingSimmetricBeliefContext routingSymmetric,
            RoutingBusBeliefContext routingBus,
            RoutingTrainBeliefContext routingTrain,
            IUtilityFunctionStrategy utilityFunction,
            ModeAttributesCalculator modeAttributesCalculator);
}
