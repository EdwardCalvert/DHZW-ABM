package main.java.nl.uu.iss.ga;

import main.java.nl.uu.iss.ga.model.data.Activity;
import main.java.nl.uu.iss.ga.simulation.DefaultTimingSimulationEngine;
import main.java.nl.uu.iss.ga.simulation.EnvironmentInterface;
import main.java.nl.uu.iss.ga.simulation.NoRescheduleBlockingTickExecutor;
import main.java.nl.uu.iss.ga.simulation.modalselection.ModalSelectionProvider;
import main.java.nl.uu.iss.ga.simulation.utilityfunctions.UtilFunctionProvider;
import main.java.nl.uu.iss.ga.util.Java2APLLogger;
import main.java.nl.uu.iss.ga.util.config.ArgParse;
import main.java.nl.uu.iss.ga.util.config.ConfigModel;
import main.java.nl.uu.iss.ga.util.tracking.ModeOfTransportTracker;
import nl.uu.cs.iss.ga.sim2apl.core.defaults.messenger.DefaultMessenger;
import nl.uu.cs.iss.ga.sim2apl.core.platform.Platform;
import nl.uu.cs.iss.ga.sim2apl.core.tick.SimulationEngine;

import java.time.LocalDateTime;
import java.util.logging.Logger;

public class Simulation {
    private static final Logger LOGGER = Logger.getLogger(Simulation.class.getName());
    public static final LocalDateTime instantiated = LocalDateTime.now();

    public static void main(String[] args) {
        ArgParse parser = new ArgParse(args);
        new Simulation(parser);
    }

    private final ArgParse arguments;

    private Platform platform;
    private NoRescheduleBlockingTickExecutor<Activity> tickExecutor;
    private ModeOfTransportTracker modeOfTransportTracker = new ModeOfTransportTracker();
    private EnvironmentInterface environmentInterface;
    private SimulationEngine<Activity> simulationEngine;
    private ConfigModel config;

    public Simulation(ArgParse arguments) {
        this.arguments = arguments;
        this.tickExecutor = new NoRescheduleBlockingTickExecutor<>(this.arguments.getThreads(), this.arguments.getSystemWideRandom());

        this.config = this.arguments.getConfigModel();


        preparePlatform();
        UtilFunctionProvider utilFunctionProvider = new UtilFunctionProvider(this.arguments.getParameterSetFile(),this.arguments.getParameterSetIndex(),this.config.getUtilFunction());
        ModalSelectionProvider modalSelectionProvider = new ModalSelectionProvider(this.config.getModalSelectionStrategy(),this.config.getRandom());

        this.config.createAgents(this.platform, this.environmentInterface, modeOfTransportTracker,utilFunctionProvider, modalSelectionProvider);

        this.environmentInterface.setSimulationStarted();
        this.simulationEngine.start();
    }

    private void preparePlatform() {
        DefaultMessenger messenger = new DefaultMessenger();

        this.platform = Platform.newPlatform(tickExecutor, messenger);
        this.platform.setLogger(new Java2APLLogger());
        this.environmentInterface = new EnvironmentInterface(
                this.arguments,
                this.modeOfTransportTracker,
                this.config
        );
        this.simulationEngine = getLocalSimulationEngine();
    }

    private SimulationEngine<Activity> getLocalSimulationEngine() {
        return new DefaultTimingSimulationEngine<>(this.platform, this.arguments, (int)this.arguments.getIterations(), this.environmentInterface);
    }

}
