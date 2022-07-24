package fsm;

class FSM<S:String, TFSM:FSM<S, TFSM>> {
    private var states:Map<S, State<S, TFSM>> = new Map();
    public var currentStateName(default, null):S;
    public var verbose:Bool = false;

    public function new(verbose = false) {
        this.verbose = verbose;
    }

    public function addState(name:S, state:State<S, TFSM>):Void {
        states.set(name, state);
        state.fsm = cast this;
    }


    public function forceChangeState(name:S) {
        changeStateinternal(name);
    }

    public function changeState(name:S):Void {
        if (currentStateName == name) return;
        changeStateinternal(name);
    }

    inline function changeStateinternal(name:S):Void {
        var targetState:State<S, TFSM> = states.get(name);
        if (targetState == null) throw "There is no state '" + name + "'";
        if (currentStateName != null && states.exists(currentStateName)) {
            var currentState:State<S, TFSM> = states.get(currentStateName);
            currentState.onExit();
        }
        #if debug
        if (verbose)
            trace("Change to " + name);
        #end
        currentStateName = name;
        targetState.onEnter();
    }


    public function getCurrentState():State<S, TFSM> {
        return states.get(currentStateName);
    }

    public function update(t:Float) {
        var state = getCurrentState();
        if(state == null)
            return;
        state.update(t);
    }
}

