package com.bloodbank.util;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.time.LocalDateTime;
import java.time.Duration;
import java.time.temporal.ChronoUnit;

@WebListener
public class NewsletterSchedulerListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent event) {
        System.out.println("🚀 LifeFlow Newsletter Scheduler initializing...");
        scheduler = Executors.newScheduledThreadPool(1);

        // 1. Weekly Health Tips (Every Monday at 9:00 AM)
        long initialDelayWeekly = calculateDelayUntil(1, 9); // Day 1 = Monday
        scheduler.scheduleAtFixedRate(
            () -> NewsletterService.sendWeeklyHealthTips(),
            initialDelayWeekly,
            7 * 24 * 60, // 7 days in minutes
            TimeUnit.MINUTES
        );

        // 2. Monthly Impact Report (1st of every month at 10:00 AM)
        long initialDelayMonthly = calculateDelayUntilMonthStart(10);
        scheduler.scheduleAtFixedRate(
            () -> NewsletterService.sendMonthlyImpactReport(),
            initialDelayMonthly,
            30 * 24 * 60, // ~30 days in minutes
            TimeUnit.MINUTES
        );
        
        System.out.println("✅ Newsletter Scheduler active. Weekly delay: " + initialDelayWeekly + " min, Monthly delay: " + initialDelayMonthly + " min.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
        if (scheduler != null) {
            scheduler.shutdownNow();
            System.out.println("🛑 Newsletter Scheduler shut down.");
        }
    }

    private long calculateDelayUntil(int dayOfWeek, int hour) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime nextRun = now.withHour(hour).withMinute(0).withSecond(0).withNano(0);
        
        while (nextRun.getDayOfWeek().getValue() != dayOfWeek || nextRun.isBefore(now)) {
            nextRun = nextRun.plusDays(1);
        }
        
        return Duration.between(now, nextRun).toMinutes();
    }

    private long calculateDelayUntilMonthStart(int hour) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime nextRun = now.withDayOfMonth(1).withHour(hour).withMinute(0).withSecond(0).withNano(0);
        
        if (nextRun.isBefore(now)) {
            nextRun = nextRun.plusMonths(1);
        }
        
        return Duration.between(now, nextRun).toMinutes();
    }
}
