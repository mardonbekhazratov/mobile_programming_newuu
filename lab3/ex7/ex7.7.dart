enum OrderEvent { pay, ship, deliver, cancel, refund }

enum OrderState {
    created(description: "Order created"),
    paid(description: "Payment received"),
    shipped(description: "Package shipped"),
    delivered(description: "Delivered to customer"),
    cancelled(description: "Order cancelled"),
    refunded(description: "Money returned");

    final String description;
    const OrderState({required this.description});

    // The whole transition table lives inside the enum.
    OrderState? next(OrderEvent event) => switch((this, event)){
        (created, OrderEvent.pay) => paid,
        (created, OrderEvent.cancel) => cancelled,
        (paid, OrderEvent.ship) => shipped,
        (paid, OrderEvent.cancel) => refunded,
        (shipped, OrderEvent.deliver) => delivered,
        (delivered, OrderEvent.refund) => refunded,
        _ => null,
    };

    List<OrderEvent> get allowedEvents =>
        OrderEvent.values.where((e) => next(e) != null).toList();

    bool get isFinal => allowedEvents.isEmpty;
}

class OrderStateMachine {
    OrderState _state = OrderState.created;
    final List<OrderState> history = [OrderState.created];

    OrderState get state => _state;

    bool fire(OrderEvent event){
        OrderState? target = _state.next(event);
        if(target == null){
            print("  ! '${event.name}' is not allowed in state '${_state.name}'");
            return false;
        }
        print("  ${_state.name} --${event.name}--> ${target.name}: ${target.description}");
        _state = target;
        history.add(target);
        return true;
    }
}

void main(){
    OrderStateMachine order = OrderStateMachine();
    List<OrderEvent> events = [
        OrderEvent.ship, OrderEvent.pay, OrderEvent.ship,
        OrderEvent.pay, OrderEvent.deliver, OrderEvent.refund,
    ];

    for(OrderEvent e in events){
        order.fire(e);
        if(order.state.isFinal){
            print("  reached final state");
            break;
        }
        print("  allowed now: ${order.state.allowedEvents.map((e) => e.name).toList()}");
    }
    print("History: ${order.history.map((s) => s.name).join(" -> ")}");
}
