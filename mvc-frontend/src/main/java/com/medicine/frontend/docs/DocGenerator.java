package com.medicine.frontend.docs;

import org.apache.poi.xwpf.usermodel.*;
import org.apache.poi.xwpf.usermodel.UnderlinePatterns;
import org.openxmlformats.schemas.wordprocessingml.x2006.main.*;

import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

/**
 * Generates Medicine-App-Guide.docx documenting the entire microservices application.
 * Run as a standalone main class:
 *   mvn exec:java -pl mvc-frontend -Dexec.mainClass=com.medicine.frontend.docs.DocGenerator
 */
public class DocGenerator {

    public static void main(String[] args) throws IOException {
        try (XWPFDocument doc = new XWPFDocument();
             FileOutputStream out = new FileOutputStream("Medicine-App-Guide.docx")) {
            new DocGenerator().generate(doc);
            doc.write(out);
        }
        System.out.println("Medicine-App-Guide.docx generated successfully.");
    }

    private void generate(XWPFDocument doc) {
        // Title
        heading(doc, "Medicine Selling App — Developer Guide", 1, true);
        para(doc, "This document provides a complete reference for the Medicine Selling microservices application built with Spring Boot 3.4.1, Spring Cloud 2024.0.0, MySQL 8, Redis 7, Kafka, Eureka, and a JSP + Bootstrap 5 / Tailwind CSS frontend.");

        // 1. Architecture overview
        heading(doc, "1. Architecture Overview", 1, false);
        para(doc, "The application follows a microservices architecture with the following components:");
        List<String[]> services = Arrays.asList(
            new String[]{"eureka-server",       "3000", "Service registry (Eureka)"},
            new String[]{"api-gateway",         "3001", "Spring Cloud Gateway + JWT validation"},
            new String[]{"auth-service",        "3002", "User registration, login, JWT issuance"},
            new String[]{"medicine-service",    "3003", "Medicine + SKU catalog, Redis cache"},
            new String[]{"order-service",       "3004", "Orders, Customers, Addresses, Payments, Kafka"},
            new String[]{"notification-service","3005", "Kafka consumer — logs email notifications"},
            new String[]{"mvc-frontend",        "3006", "Spring MVC WAR, JSP views, session auth"}
        );
        String[][] serviceRows = services.stream()
            .map(r -> r)
            .toArray(String[][]::new);
        table(doc, new String[]{"Service", "Port", "Responsibility"}, serviceRows);

        // 2. Infrastructure
        heading(doc, "2. Infrastructure Dependencies", 1, false);
        table(doc,
            new String[]{"Component", "Image", "Port"},
            new String[][]{
                {"MySQL 8",     "mysql:8.0",                      "3306"},
                {"Redis 7",     "redis:7-alpine",                 "6379"},
                {"Zookeeper",   "confluentinc/cp-zookeeper:7.6.0","2181"},
                {"Kafka",       "confluentinc/cp-kafka:7.6.0",   "9092"}
            });

        // 3. API Endpoints
        heading(doc, "3. REST API Endpoints", 1, false);

        heading(doc, "3.1 Auth Service (/api/auth)", 2, false);
        table(doc,
            new String[]{"Method", "Path", "Auth", "Description"},
            new String[][]{
                {"POST", "/api/auth/register",              "None",  "Register new user"},
                {"POST", "/api/auth/login",                 "None",  "Login and get JWT"},
                {"GET",  "/api/auth/me",                    "JWT",   "Get current user details"},
                {"GET",  "/api/auth/users",                 "ADMIN", "List all users"},
                {"PUT",  "/api/auth/users/{id}/inactivate", "ADMIN", "Inactivate a user"}
            });

        heading(doc, "3.2 Medicine Service (/api/medicines, /api/skus)", 2, false);
        table(doc,
            new String[]{"Method", "Path", "Auth", "Description"},
            new String[][]{
                {"GET",    "/api/medicines",                        "JWT",   "Available medicines (with active SKUs)"},
                {"GET",    "/api/medicines/all",                    "ADMIN", "All medicines including inactive SKUs"},
                {"GET",    "/api/medicines/{id}",                   "JWT",   "Single medicine"},
                {"GET",    "/api/medicines/{id}/skus",              "JWT",   "Available SKUs for a medicine"},
                {"GET",    "/api/medicines/{id}/skus/all",          "ADMIN", "All SKUs for a medicine"},
                {"POST",   "/api/medicines",                        "ADMIN", "Create medicine"},
                {"PUT",    "/api/medicines/{id}",                   "ADMIN", "Update medicine"},
                {"DELETE", "/api/medicines/{id}",                   "ADMIN", "Delete medicine"},
                {"POST",   "/api/medicines/{id}/deduct-stock",      "JWT",   "Deduct SKU stock"},
                {"POST",   "/api/skus/medicine/{medicineId}",       "ADMIN", "Create SKU"},
                {"PUT",    "/api/skus/{skuId}",                     "ADMIN", "Update SKU"},
                {"PUT",    "/api/skus/{skuId}/inactivate",          "ADMIN", "Inactivate SKU"}
            });

        heading(doc, "3.3 Order Service", 2, false);
        table(doc,
            new String[]{"Method", "Path", "Auth", "Description"},
            new String[][]{
                {"POST", "/api/orders",                           "JWT",   "Place new order"},
                {"GET",  "/api/orders/my",                        "JWT",   "My orders"},
                {"GET",  "/api/orders",                           "ADMIN", "All orders (optional ?status=)"},
                {"PUT",  "/api/orders/{id}/cancel",               "JWT",   "Cancel order"},
                {"PUT",  "/api/orders/{id}/status",               "ADMIN", "Update order status"},
                {"POST", "/api/customers",                        "JWT",   "Create customer"},
                {"GET",  "/api/customers",                        "JWT",   "List customers for user"},
                {"PUT",  "/api/customers/{id}/inactivate",        "ADMIN", "Inactivate customer"},
                {"POST", "/api/addresses",                        "JWT",   "Save/reuse address"},
                {"GET",  "/api/addresses/user/{userId}",          "JWT",   "List addresses for user"},
                {"GET",  "/api/payments",                         "ADMIN", "All payments"},
                {"GET",  "/api/audit-logs",                       "ADMIN", "Paginated audit log"}
            });

        // 4. Sample cURL
        heading(doc, "4. Sample cURL Commands", 1, false);

        heading(doc, "Register a user", 2, false);
        code(doc, "curl -X POST http://localhost:3001/api/auth/register \\\n" +
            "  -H 'Content-Type: application/json' \\\n" +
            "  -d '{\"name\":\"John Doe\",\"email\":\"john@example.com\",\"password\":\"pass1234\"}'");

        heading(doc, "Login and get token", 2, false);
        code(doc, "curl -X POST http://localhost:3001/api/auth/login \\\n" +
            "  -H 'Content-Type: application/json' \\\n" +
            "  -d '{\"email\":\"john@example.com\",\"password\":\"pass1234\"}'");

        heading(doc, "List available medicines", 2, false);
        code(doc, "curl http://localhost:3001/api/medicines \\\n" +
            "  -H 'Authorization: Bearer <JWT_TOKEN>'");

        heading(doc, "Place an order", 2, false);
        code(doc, "curl -X POST http://localhost:3001/api/orders \\\n" +
            "  -H 'Authorization: Bearer <JWT_TOKEN>' \\\n" +
            "  -H 'Content-Type: application/json' \\\n" +
            "  -d '{\n" +
            "    \"customerId\": 1,\n" +
            "    \"shippingAddressId\": 1,\n" +
            "    \"items\": [{\"skuId\": 1, \"quantity\": 2}]\n" +
            "  }'");

        // 5. Docker Compose startup guide
        heading(doc, "5. Docker Compose — Startup Guide", 1, false);
        para(doc, "Prerequisites: Docker Desktop 4.x+ with Compose V2.");
        heading(doc, "Build and start all services", 2, false);
        code(doc, "# From the project root directory:\ndocker compose up --build -d");
        heading(doc, "Check running containers", 2, false);
        code(doc, "docker compose ps");
        heading(doc, "View logs for a specific service", 2, false);
        code(doc, "docker compose logs -f order-service");
        heading(doc, "Stop all services", 2, false);
        code(doc, "docker compose down");
        heading(doc, "Stop and wipe volumes (fresh DB)", 2, false);
        code(doc, "docker compose down -v");
        para(doc, "Note: On first startup MySQL initialises from db/init.sql which seeds 20 medicines, their SKUs, and an admin user. Wait for all containers to show healthy before accessing the UI.");

        // 6. Default credentials
        heading(doc, "6. Default Credentials & URLs", 1, false);
        table(doc,
            new String[]{"Item", "Value"},
            new String[][]{
                {"Admin email",      "admin@medicine.com"},
                {"Admin password",   "admin123"},
                {"Frontend UI",      "http://localhost:3006"},
                {"Eureka Dashboard", "http://localhost:3000"},
                {"API Gateway",      "http://localhost:3001"},
                {"MySQL DB name",    "medicine_db"},
                {"MySQL root password", "root"},
                {"JWT Secret",       "Medicine$SecretKey2024!VeryLongAndSecure"},
                {"Redis host:port",  "localhost:6379"},
                {"Kafka broker",     "localhost:9092"}
            });

        // 7. Kafka topics
        heading(doc, "7. Kafka Topics", 1, false);
        table(doc,
            new String[]{"Topic", "Producer", "Consumer", "Event"},
            new String[][]{
                {"order-placed",    "order-service", "notification-service", "Fired on new order — triggers order confirmation email"},
                {"order-cancelled", "order-service", "notification-service", "Fired on order cancellation — triggers cancellation email"}
            });

        // 8. Caching
        heading(doc, "8. Redis Caching", 1, false);
        table(doc,
            new String[]{"Cache Name", "Key", "TTL", "Evicted On"},
            new String[][]{
                {"medicines", "\"all\"",   "600s", "createMedicine, updateMedicine, deleteMedicine, inactivateSku, updateSku, createSku"},
                {"medicine",  "medicineId","600s", "Same mutations as above"}
            });

        // 9. Audit logging
        heading(doc, "9. Audit Logging", 1, false);
        para(doc, "All privileged actions are recorded in the audit_log table via AuditService in common-lib. Logged actions:");
        List<String> actions = Arrays.asList(
            "CREATE_ORDER — when a new order is placed",
            "ORDER_STATUS_UPDATE — when an admin changes order status",
            "CANCEL_ORDER — when an order is cancelled",
            "INACTIVATE_USER — when an admin inactivates a user account",
            "INACTIVATE_SKU — when an admin inactivates a SKU",
            "CREATE_SKU — when an admin creates a new SKU",
            "UPDATE_SKU — when an admin updates a SKU",
            "INACTIVATE_CUSTOMER — when an admin inactivates a customer"
        );
        for (String a : actions) {
            bullet(doc, a);
        }
        para(doc, "Audit logs are viewable at: Admin Dashboard → Audit Log (paginated, with JSON diff viewer).");

        // 10. Step-by-Step Startup Guide
        heading(doc, "10. Step-by-Step Guide — How to Start the Application", 1, false);
        para(doc, "Follow these steps in order to get the full application running on your local machine using Docker.");

        heading(doc, "Prerequisites", 2, false);
        para(doc, "Make sure the following tools are installed before you begin:");
        bullet(doc, "Docker Desktop 4.x or later (with Compose V2 enabled)");
        bullet(doc, "Java 17+ (only needed if you want to build/run services without Docker)");
        bullet(doc, "Maven 3.9+ (only needed for local builds outside Docker)");
        bullet(doc, "Git (to clone the repository)");
        doc.createParagraph();

        heading(doc, "Step 1 — Clone the Repository", 2, false);
        code(doc, "git clone https://github.com/your-org/Medicine-Selling-Mvc-App.git\ncd Medicine-Selling-Mvc-App");

        heading(doc, "Step 2 — Verify Docker is Running", 2, false);
        para(doc, "Open Docker Desktop and ensure the Docker engine is active (green status icon). Then verify from terminal:");
        code(doc, "docker --version\ndocker compose version");

        heading(doc, "Step 3 — Build All Docker Images and Start All Services", 2, false);
        para(doc, "This single command builds every service image from source and starts all 11 containers (MySQL, Redis, Zookeeper, Kafka, Eureka, Gateway, Auth, Medicine, Order, Notification, Frontend):");
        code(doc, "docker compose up --build -d");
        para(doc, "The --build flag forces Maven to compile all modules inside Docker. The -d flag runs everything in the background. This may take 5-10 minutes on the first run while Maven downloads dependencies.");

        heading(doc, "Step 4 — Monitor Startup Progress", 2, false);
        para(doc, "Watch all service logs in real time:");
        code(doc, "docker compose logs -f");
        para(doc, "Or watch logs for a specific service:");
        code(doc, "docker compose logs -f eureka-server\ndocker compose logs -f api-gateway\ndocker compose logs -f mvc-frontend");
        para(doc, "Wait until you see 'Started ... Application' in the logs for each service before proceeding.");

        heading(doc, "Step 5 — Verify All Containers are Healthy", 2, false);
        para(doc, "Check that all containers are running and healthy:");
        code(doc, "docker compose ps");
        para(doc, "Expected: all 11 services should show Status = Up (healthy). If any show 'Restarting', check its logs:");
        code(doc, "docker compose logs <service-name>");

        heading(doc, "Step 6 — Verify Eureka Service Registry", 2, false);
        para(doc, "Open the Eureka dashboard in your browser to confirm all microservices have registered:");
        code(doc, "http://localhost:3000");
        para(doc, "You should see: AUTH-SERVICE, MEDICINE-SERVICE, ORDER-SERVICE, NOTIFICATION-SERVICE, MVC-FRONTEND, and API-GATEWAY all listed as UP.");

        heading(doc, "Step 7 — Open the Application UI", 2, false);
        para(doc, "Open the frontend in your browser:");
        code(doc, "http://localhost:3006");

        heading(doc, "Step 8 — Login as Admin", 2, false);
        para(doc, "Use the pre-seeded admin credentials to log in:");
        table(doc,
            new String[]{"Field", "Value"},
            new String[][]{
                {"Email",    "admin@medicine.com"},
                {"Password", "admin123"}
            });
        para(doc, "After login you will be redirected to the Admin Dashboard with access to all management features.");

        heading(doc, "Step 9 — Register as a Guest User (Optional)", 2, false);
        para(doc, "Click 'Register' on the home page and fill in your name, email and password. Guest users can browse medicines, add to cart, and place orders.");

        heading(doc, "Step 10 — Place Your First Order", 2, false);
        para(doc, "As a logged-in user (Guest or Admin):");
        bullet(doc, "Go to Medicines → browse the catalog");
        bullet(doc, "Click 'Add to Cart' on any medicine, choose a SKU and quantity");
        bullet(doc, "Click the floating cart button → Review Cart → Proceed to Checkout");
        bullet(doc, "Select or create a Customer profile");
        bullet(doc, "Select or add a Shipping Address");
        bullet(doc, "Confirm payment method (Cash on Delivery) → Place Order");
        bullet(doc, "A Kafka event fires and the console logs a simulated email notification");
        doc.createParagraph();

        heading(doc, "Useful Management Commands", 2, false);
        table(doc,
            new String[]{"Task", "Command"},
            new String[][]{
                {"Start all services (background)",    "docker compose up -d"},
                {"Rebuild and start",                  "docker compose up --build -d"},
                {"Stop all services",                  "docker compose down"},
                {"Stop & delete volumes (fresh DB)",   "docker compose down -v"},
                {"View logs (all services)",           "docker compose logs -f"},
                {"View logs (one service)",            "docker compose logs -f <service-name>"},
                {"Restart one service",                "docker compose restart <service-name>"},
                {"Check container health",             "docker compose ps"},
                {"Open MySQL shell",                   "docker exec -it medicine-mysql mysql -uroot -proot medicine_db"},
                {"Flush Redis cache",                  "docker exec -it medicine-redis redis-cli FLUSHALL"},
                {"List Kafka topics",                  "docker exec -it medicine-kafka kafka-topics --bootstrap-server localhost:9092 --list"}
            });

        heading(doc, "Service URLs Quick Reference", 2, false);
        table(doc,
            new String[]{"Service", "URL"},
            new String[][]{
                {"Frontend UI",          "http://localhost:3006"},
                {"Eureka Dashboard",     "http://localhost:3000"},
                {"API Gateway",          "http://localhost:3001"},
                {"Auth Service",         "http://localhost:3002"},
                {"Medicine Service",     "http://localhost:3003"},
                {"Order Service",        "http://localhost:3004"},
                {"Notification Service", "http://localhost:3005"}
            });

        heading(doc, "Troubleshooting", 2, false);
        table(doc,
            new String[]{"Problem", "Fix"},
            new String[][]{
                {"Port already in use",               "Run: docker compose down, then check with: netstat -ano | findstr :<PORT>"},
                {"MySQL not ready — services crashing","Wait 30s and run: docker compose restart auth-service medicine-service order-service"},
                {"Kafka consumer not connecting",      "Wait for kafka container to be healthy, then: docker compose restart notification-service order-service"},
                {"Services not appearing in Eureka",   "Wait 60s — Eureka heartbeat interval. Then refresh http://localhost:3000"},
                {"Frontend shows 502 Bad Gateway",     "The api-gateway may still be starting. Wait 30s and refresh."},
                {"Fresh start (wipe everything)",       "docker compose down -v && docker compose up --build -d"}
            });
    }

    // ── Helpers ─────────────────────────────────────────────────────────────────

    private void heading(XWPFDocument doc, String text, int level, boolean isTitle) {
        XWPFParagraph p = doc.createParagraph();
        // Add spacing before each heading
        p.setSpacingBefore(isTitle ? 0 : (level == 1 ? 300 : 160));
        p.setSpacingAfter(80);
        XWPFRun run = p.createRun();
        run.setText(text);
        run.setBold(true);
        if (isTitle) {
            run.setFontSize(22);
            run.setColor("1E3A8A");
        } else if (level == 1) {
            run.setFontSize(15);
            run.setColor("1D4ED8");
            // Underline for H1
            run.setUnderline(UnderlinePatterns.SINGLE);
        } else {
            run.setFontSize(12);
            run.setColor("1E40AF");
        }
    }

    private void para(XWPFDocument doc, String text) {
        XWPFParagraph p = doc.createParagraph();
        p.setSpacingAfter(60);
        XWPFRun run = p.createRun();
        run.setText(text);
        run.setFontSize(10);
        run.setColor("111827");
    }

    private void bullet(XWPFDocument doc, String text) {
        XWPFParagraph p = doc.createParagraph();
        p.setIndentationLeft(360);
        p.setSpacingAfter(40);
        XWPFRun run = p.createRun();
        run.setText("\u2022  " + text);
        run.setFontSize(10);
        run.setColor("374151");
    }

    private void code(XWPFDocument doc, String text) {
        String[] lines = text.split("\n");
        for (String line : lines) {
            XWPFParagraph p = doc.createParagraph();
            p.setIndentationLeft(360);
            p.setSpacingAfter(0);
            // Light gray background via shading on the paragraph
            CTPPr ppr = p.getCTP().isSetPPr() ? p.getCTP().getPPr() : p.getCTP().addNewPPr();
            CTShd shd = ppr.isSetShd() ? ppr.getShd() : ppr.addNewShd();
            shd.setFill("F3F4F6");
            shd.setVal(STShd.CLEAR);
            XWPFRun run = p.createRun();
            run.setFontFamily("Courier New");
            run.setFontSize(9);
            run.setColor("1F2937");
            run.setText(line.isEmpty() ? " " : line);
        }
        // Small gap after code block
        XWPFParagraph gap = doc.createParagraph();
        gap.setSpacingAfter(80);
    }

    private void table(XWPFDocument doc, String[] headers, String[][] rows) {
        XWPFTable table = doc.createTable(1 + rows.length, headers.length);
        table.setWidth(5000); // 100% in twips-like units for POI

        // Header row
        XWPFTableRow headerRow = table.getRow(0);
        for (int i = 0; i < headers.length; i++) {
            XWPFTableCell cell = headerRow.getCell(i);
            cell.setColor("1E40AF");
            XWPFParagraph p = cell.getParagraphs().get(0);
            XWPFRun run = p.createRun();
            run.setText(headers[i]);
            run.setBold(true);
            run.setColor("FFFFFF");
            run.setFontSize(9);
        }

        // Data rows
        for (int r = 0; r < rows.length; r++) {
            XWPFTableRow row = table.getRow(r + 1);
            for (int c = 0; c < rows[r].length; c++) {
                XWPFTableCell cell = row.getCell(c);
                if (cell == null) cell = row.addNewTableCell();
                XWPFParagraph p = cell.getParagraphs().get(0);
                XWPFRun run = p.createRun();
                run.setText(rows[r][c]);
                run.setFontSize(9);
                if (r % 2 == 1) cell.setColor("EFF6FF");
            }
        }

        // Spacer paragraph after table
        doc.createParagraph();
    }
}
