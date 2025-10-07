# UniCloud Debug Guide

## Quick Start

### Option 1: Start with Debug (No Wait)
Application starts immediately, you can attach debugger anytime:
```bash
./start-backend-debug.sh
```

### Option 2: Start with Debug (Wait for Debugger)
Application waits for debugger before starting:
```bash
./start-backend-debug-suspend.sh
```

---

## IDE Debug Configurations

### IntelliJ IDEA

**Pre-configured run configurations available:**
1. Open Run → Edit Configurations
2. Select "UniCloud Backend (Debug)" from Remote configurations
3. Click Debug button

**Manual setup:**
1. Run → Edit Configurations → Add New → Remote JVM Debug
2. Set:
   - Name: `UniCloud Debug`
   - Host: `localhost`
   - Port: `5005`
   - Command line args: `-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005`
3. Start backend with `./start-backend-debug.sh`
4. Click Debug in IntelliJ

### VS Code

**Pre-configured:**
1. Open Run and Debug (Ctrl+Shift+D)
2. Select "Debug UniCloud Backend" from dropdown
3. Start backend with `./start-backend-debug.sh`
4. Press F5 to attach

**Manual setup:**
Configuration already in `.vscode/launch.json`

### Eclipse

1. Run → Debug Configurations → Remote Java Application → New
2. Set:
   - Project: `unicloud-backend`
   - Connection Type: Standard (Socket Attach)
   - Host: `localhost`
   - Port: `5005`
3. Start backend with `./start-backend-debug.sh`
4. Click Debug

### Neovim (nvim-dap)

Add to your nvim-dap configuration:
```lua
local dap = require('dap')

dap.configurations.java = {
  {
    type = 'java',
    request = 'attach',
    name = 'Attach to UniCloud Backend',
    hostName = 'localhost',
    port = 5005,
  }
}
```

Start backend with `./start-backend-debug.sh`, then in Neovim:
```
:lua require'dap'.continue()
```

---

## Debug Scripts

### start-backend-debug.sh
- Starts backend with debug enabled
- **suspend=n** - Application starts immediately
- Debugger can attach at any time
- Best for: General debugging

### start-backend-debug-suspend.sh
- Starts backend with debug enabled
- **suspend=y** - Application WAITS for debugger
- Use when you need to debug startup/initialization
- Best for: Debugging ApplicationContext initialization, @PostConstruct methods

---

## Debug Modes Comparison

| Mode | Script | Suspend | Use Case |
|------|--------|---------|----------|
| **Normal** | `start-backend.sh` | N/A | Production-like run |
| **Debug** | `start-backend-debug.sh` | No | Debug during development |
| **Debug Suspend** | `start-backend-debug-suspend.sh` | Yes | Debug startup issues |

---

## Common Debug Tasks

### 1. Debug a REST Endpoint
```bash
# Start with debug
./start-backend-debug.sh

# Set breakpoint in your IDE at:
# unicloud-backend/src/main/java/com/unicloud/backend/controller/UserController.java:45

# Attach debugger from IDE

# Make API call:
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","password":"pass123"}'
```

### 2. Debug Application Startup
```bash
# Start with suspend (waits for debugger)
./start-backend-debug-suspend.sh

# Set breakpoint in:
# unicloud-backend/src/main/java/com/unicloud/backend/UniCloudBackendApplication.java

# Attach debugger - application will start and hit breakpoint
```

### 3. Debug Tests
```bash
# Run specific test with debug
mvn test -Dtest=UserServiceTest -Dmaven.surefire.debug

# IDE will show:
# Listening for transport dt_socket at address: 5005
# Attach debugger to port 5005
```

### 4. Debug Database Queries
```bash
# Start with debug
./start-backend-debug.sh

# Enable SQL logging in application.properties:
# spring.jpa.show-sql=true
# spring.jpa.properties.hibernate.format_sql=true
# logging.level.org.hibernate.SQL=DEBUG
# logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE

# Set breakpoint in repository or service method
```

---

## Troubleshooting

### Port 5005 already in use
```bash
# Find and kill process using port 5005
lsof -ti:5005 | xargs kill -9

# Or let the script handle it (answer 'y' when prompted)
```

### Debugger won't connect
1. Check backend is running with debug enabled:
   ```bash
   lsof -i :5005
   ```
2. Verify firewall allows localhost:5005
3. Check IDE debugger configuration matches port 5005

### Application won't start
1. Check logs for errors
2. Verify PostgreSQL is running:
   ```bash
   docker ps | grep postgres
   ```
3. Check port 8080 is not in use

### Breakpoints not hitting
1. Ensure source code matches compiled bytecode
2. Rebuild: `mvn clean compile`
3. Restart backend with debug
4. Re-attach debugger

---

## Advanced Debugging

### Remote Debugging (Production)
**WARNING**: Never enable in production unless necessary

If you must debug production:
```bash
# On production server, start with:
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=0.0.0.0:5005 -jar app.jar

# From your machine:
# 1. SSH tunnel:
ssh -L 5005:localhost:5005 production-server

# 2. Attach debugger to localhost:5005
```

### Conditional Breakpoints
In your IDE:
1. Right-click breakpoint
2. Add condition:
   ```java
   username.equals("admin")
   // or
   userId != null && userId > 100
   ```

### Logging Breakpoints
Log without stopping execution:
1. Right-click breakpoint
2. Uncheck "Suspend"
3. Check "Log evaluated expression"
4. Enter: `"User created: " + user.getUsername()`

---

## Environment Variables for Debugging

Set in IDE run configuration or export before running:

```bash
# Database
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5433/unicloud_dev
export SPRING_DATASOURCE_USERNAME=dev_user
export SPRING_DATASOURCE_PASSWORD=dev_password

# Logging
export LOGGING_LEVEL_ROOT=INFO
export LOGGING_LEVEL_COM_UNICLOUD=DEBUG
export LOGGING_LEVEL_ORG_SPRINGFRAMEWORK_SECURITY=DEBUG

# Debug SQL
export SPRING_JPA_SHOW_SQL=true
export SPRING_JPA_PROPERTIES_HIBERNATE_FORMAT_SQL=true
```

---

## Performance Profiling

### Enable JMX
```bash
mvn spring-boot:run -pl unicloud-backend \
  -Dspring-boot.run.jvmArguments="-Dcom.sun.management.jmxremote \
    -Dcom.sun.management.jmxremote.port=9010 \
    -Dcom.sun.management.jmxremote.authenticate=false \
    -Dcom.sun.management.jmxremote.ssl=false"
```

Connect with VisualVM or JConsole to `localhost:9010`

### Enable Flight Recorder
```bash
mvn spring-boot:run -pl unicloud-backend \
  -Dspring-boot.run.jvmArguments="-XX:StartFlightRecording=duration=60s,filename=/tmp/recording.jfr"
```

Analyze with JDK Mission Control

---

## Quick Reference

| Task | Command |
|------|---------|
| Start with debug | `./start-backend-debug.sh` |
| Start and wait for debugger | `./start-backend-debug-suspend.sh` |
| Debug tests | `mvn test -Dtest=TestName -Dmaven.surefire.debug` |
| Check debug port | `lsof -i :5005` |
| Kill debug port | `lsof -ti:5005 \| xargs kill -9` |
| View logs | `tail -f /tmp/unicloud-backend.log` |

---

## Resources

- [Spring Boot Debug Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/using.html#using.running-your-application.with-the-maven-plugin)
- [Java Debug Wire Protocol (JDWP)](https://docs.oracle.com/javase/8/docs/technotes/guides/jpda/jdwp-spec.html)
- [IntelliJ IDEA Remote Debug](https://www.jetbrains.com/help/idea/tutorial-remote-debug.html)
- [VS Code Java Debugging](https://code.visualstudio.com/docs/java/java-debugging)
