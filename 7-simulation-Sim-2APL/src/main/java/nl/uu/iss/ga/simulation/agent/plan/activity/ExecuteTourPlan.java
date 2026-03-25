package main.java.nl.uu.iss.ga.simulation.agent.plan.activity;

import main.java.nl.uu.iss.ga.model.data.*;

import main.java.nl.uu.iss.ga.model.data.dictionary.TwoStringKeys;
import main.java.nl.uu.iss.ga.simulation.modalselection.*;
import main.java.nl.uu.iss.ga.simulation.utilityfunctions.IUtilityFunctionStrategy;
import main.java.nl.uu.iss.ga.simulation.agent.context.BeliefContext;
import main.java.nl.uu.iss.ga.simulation.agent.context.RoutingBusBeliefContext;
import main.java.nl.uu.iss.ga.simulation.agent.context.RoutingSimmetricBeliefContext;
import main.java.nl.uu.iss.ga.simulation.agent.context.RoutingTrainBeliefContext;
import main.java.nl.uu.iss.ga.simulation.utilityfunctions.UtilFunctionProvider;
import nl.uu.cs.iss.ga.sim2apl.core.agent.PlanToAgentInterface;
import nl.uu.cs.iss.ga.sim2apl.core.plan.builtin.RunOncePlan;

import java.util.List;
import java.util.Random;
import java.util.logging.Logger;


public class ExecuteTourPlan extends RunOncePlan<TripTour> {
    private static final Logger LOGGER = Logger.getLogger(ExecuteTourPlan.class.getName());
    private final ActivityTour activityTour;
    private final long pid;
    private final long hid;
    private final Random _random;
    private TripTour tripTour;

    public ExecuteTourPlan(ActivityTour activityTour, Random random) {
        this.activityTour = activityTour;
        this.pid = activityTour.getPid();
        this.hid = activityTour.getHid();
        this._random = random;
    }

    /**
     * This function is called at every midnight for each action of the next day.
     *
     * @param planToAgentInterface
     * @return
     */
    @Override
    public TripTour executeOnce(PlanToAgentInterface<TripTour> planToAgentInterface) {
        List<Activity> activities = activityTour.getActivityTour();
        this.tripTour = new TripTour(activityTour.getPid(), activityTour.getDay());
        Person person = planToAgentInterface.getContext(Person.class);

        // only agents that are older than 4 years old can decide their activities
        if (person.getAge() >= 4) {

            BeliefContext beliefContext = planToAgentInterface.getContext(BeliefContext.class);
            IUtilityFunctionStrategy utilityFunction = planToAgentInterface.getContext(UtilFunctionProvider.class).getUtilityFunction();
            if (utilityFunction == null) {
                throw new RuntimeException("No Utility Function supplied");
            }
            IModalSelectionStrategy modalSelectionStrategy = planToAgentInterface.getContext(ModalSelectionProvider.class).getModalChoiceStrategy();


            RoutingSimmetricBeliefContext routingSymmetric = planToAgentInterface.getContext(RoutingSimmetricBeliefContext.class);
            RoutingBusBeliefContext routingBus = planToAgentInterface.getContext(RoutingBusBeliefContext.class);
            RoutingTrainBeliefContext routingTrain = planToAgentInterface.getContext(RoutingTrainBeliefContext.class);


            /*
             *  generation of transport mode for each trip
             */
            Activity activityOrigin = activities.get(0);

            // initialise the trip tour
            for (Activity activityDestination : activities.subList(1, activities.size())) {
                // not entirely outside DHZW and the postcodes are different
                if ((activityOrigin.getLocation().isInDHZW() || activityDestination.getLocation().isInDHZW()) && (
                        !activityOrigin.getLocation().getPostcode().equals(activityDestination.getLocation().getPostcode()))) {

                    TwoStringKeys simmetricPostcodes = new TwoStringKeys(
                            activityOrigin.getLocation().getPostcode(),
                            activityDestination.getLocation().getPostcode()
                    );

                    Trip trip = new Trip(this.pid,
                            this.hid,
                            activityOrigin,
                            activityDestination,
                            routingSymmetric.getBeelineDistance(simmetricPostcodes)
                    );
                    this.tripTour.addTrip(trip);
                }
                activityOrigin = activityDestination;
            }

            modalSelectionStrategy.assignModes(tripTour,person,beliefContext,routingSymmetric,routingBus,routingTrain,utilityFunction,new ModeAttributesCalculator());

        }
        return this.tripTour;
    }
}
