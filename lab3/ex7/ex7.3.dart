enum OrderStatus { pending, paid, shipped, delivered, cancelled }

String statusLabel(OrderStatus status) => switch(status){
    OrderStatus.pending => "Waiting for payment",
    OrderStatus.paid => "Payment received",
    OrderStatus.shipped => "On the way",
    OrderStatus.delivered => "Delivered",
    OrderStatus.cancelled => "Cancelled",
};

// No default case needed: the compiler checks that every value is covered.
String statusIcon(OrderStatus status) => switch(status){
    OrderStatus.pending || OrderStatus.paid => "[...]",
    OrderStatus.shipped => "[>>>]",
    OrderStatus.delivered => "[ok]",
    OrderStatus.cancelled => "[x]",
};

void main(){
    for(OrderStatus s in OrderStatus.values){
        print("${statusIcon(s)} ${statusLabel(s)}");
    }
}
