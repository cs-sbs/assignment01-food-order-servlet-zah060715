package cs.sbs.web.servlet;

import cs.sbs.web.model.MenuItem;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class MenuListServlet extends HttpServlet {

    private List<MenuItem> menuItems = new ArrayList<>();

    @Override
    public void init() throws ServletException {
        super.init();
        menuItems.add(new MenuItem("Fried Rice", 8));
        menuItems.add(new MenuItem("Fried Noodles", 9));
        menuItems.add(new MenuItem("Burger", 10));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String name = req.getParameter("name");
        List<MenuItem> result = menuItems;

        if (name != null && !name.isEmpty()) {
            result = menuItems.stream()
                    .filter(item -> item.getName().toLowerCase().contains(name.toLowerCase()))
                    .collect(Collectors.toList());
        }

        resp.setContentType("text/plain; charset=UTF-8");
        PrintWriter out = resp.getWriter();
        out.println("Menu List:\n");

        if (result.isEmpty()) {
            out.println("No items found.");
        } else {
            for (int i = 0; i < result.size(); i++) {
                MenuItem item = result.get(i);
                out.println((i + 1) + ". " + item.getName() + " - $" + item.getPrice());
            }
        }
    }
}
