package cs.sbs.web.servlet;

import cs.sbs.web.model.Order;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.ArrayList;

public class OrderDetailServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String pathInfo = req.getPathInfo();
        resp.setContentType("text/plain; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        if (pathInfo == null || pathInfo.equals("/")) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.println("Error: Missing order ID");
            return;
        }

        String orderIdStr = pathInfo.substring(1);
        int orderId;
        try {
            orderId = Integer.parseInt(orderIdStr);
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.println("Error: Invalid order ID format");
            return;
        }

        Object ordersAttr = getServletContext().getAttribute("orders");
        List<Order> orders = new ArrayList<>();
        if (ordersAttr instanceof List<?>) {
            for (Object o : (List<?>) ordersAttr) {
                if (o instanceof Order) {
                    orders.add((Order) o);
                }
            }
        }

        Order foundOrder = null;
        if (!orders.isEmpty()) {
            for (Order order : orders) {
                if (order.getId() == orderId) {
                    foundOrder = order;
                    break;
                }
            }
        }

        if (foundOrder != null) {
            out.println("Order Detail\n");
            out.println("Order ID: " + foundOrder.getId());
            out.println("Customer: " + foundOrder.getCustomer());
            out.println("Food: " + foundOrder.getFood());
            out.println("Quantity: " + foundOrder.getQuantity());
        } else {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            out.println("Order not found");
        }
    }
}
