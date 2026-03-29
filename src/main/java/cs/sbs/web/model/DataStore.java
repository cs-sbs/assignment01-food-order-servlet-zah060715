package cs.sbs.web.model;

import java.util.ArrayList;
import java.util.List;

public class DataStore {

    public static final List<MenuItem> MENU = new ArrayList<>();
    public static final List<Order> ORDERS = new ArrayList<>();
    private static int nextId = 1001;

    static {
        MENU.add(new MenuItem("Fried Rice", 8));
        MENU.add(new MenuItem("Fried Noodles", 9));
        MENU.add(new MenuItem("Burger", 10));
        MENU.add(new MenuItem("Noodles", 7));
    }

    public static synchronized Order createOrder(String customer, String food, int quantity) {
        int id = nextId++;
        Order o = new Order(id, customer, food, quantity);
        ORDERS.add(o);
        return o;
    }

    public static Order findOrder(int id) {
        for (Order o : ORDERS) {
            if (o.getId() == id) return o;
        }
        return null;
    }
}
