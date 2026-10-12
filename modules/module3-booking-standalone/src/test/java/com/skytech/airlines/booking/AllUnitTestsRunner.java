package com.skytech.airlines.booking;

import org.junit.jupiter.api.Test;
import java.lang.reflect.Method;

public class AllUnitTestsRunner {
    public static void main(String[] args) {
        Class<?>[] testClasses = {
            PNRGeneratorTest.class,
            PassengerValidationTest.class,
            FareCalculationTest.class,
            SeatAllocationTest.class,
            BookingServiceTransactionTest.class
        };

        int passed = 0;
        int failed = 0;

        System.out.println("===============================================================================");
        System.out.println("  RUNNING SKYTECH JUNIT 5 TEST SUITE                                           ");
        System.out.println("===============================================================================");

        for (Class<?> clazz : testClasses) {
            System.out.println("\nExecuting: " + clazz.getSimpleName());
            try {
                Object instance = clazz.getDeclaredConstructor().newInstance();

                Method setUp = null;
                try {
                    setUp = clazz.getDeclaredMethod("setUp");
                    setUp.setAccessible(true);
                } catch (NoSuchMethodException ignored) {}

                for (Method m : clazz.getDeclaredMethods()) {
                    if (m.isAnnotationPresent(Test.class)) {
                        try {
                            if (setUp != null) setUp.invoke(instance);
                            m.setAccessible(true);
                            m.invoke(instance);
                            System.out.println("  [PASS] " + m.getName());
                            passed++;
                        } catch (Exception ex) {
                            System.err.println("  [FAIL] " + m.getName() + " -> " + ex.getCause().getMessage());
                            failed++;
                        }
                    }
                }
            } catch (Exception e) {
                System.err.println("Error instantiating test class: " + clazz.getName());
                failed++;
            }
        }

        System.out.println("\n-------------------------------------------------------------------------------");
        System.out.println("  JUNIT TEST SUMMARY: " + passed + " Passed, " + failed + " Failed");
        System.out.println("===============================================================================");
    }
}
