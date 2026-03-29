package cs.sbs.web.servlet;

import cs.sbs.web.model.Order;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

public class OrderCreateServlet extends HttpServlet {

    private List<Order> orders = new ArrayList<>();
    private AtomicInteger orderIdCounter = new AtomicInteger(1000);

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("text/plain; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        String customer = req.getParameter("customer");
        String food = req.getParameter("food");
        String quantityStr = req.getParameter("quantity");

        if (customer == null || food == null || quantityStr == null ||
                customer.isEmpty() || food.isEmpty() || quantityStr.isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.println("Error: missing parameters");
            return;
        }

        int quantity;
        try {
            quantity = Integer.parseInt(quantityStr);
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.println("Error: invalid quantity");
            return;
        }

        int orderId = orderIdCounter.incrementAndGet();
        Order order = new Order(orderId, customer, food, quantity);
        orders.add(order);

        // Make orders available to other servlets
        getServletContext().setAttribute("orders", orders);

        out.println("Order Created: " + orderId);
    }
}
