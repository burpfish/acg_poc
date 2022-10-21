//package com.burfordfc.service.TestService;
//
//import com.martensigwart.fakeload.FakeLoad;
//import com.martensigwart.fakeload.FakeLoadExecutor;
//import com.martensigwart.fakeload.FakeLoadExecutors;
//import com.martensigwart.fakeload.FakeLoads;
//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.scheduling.annotation.EnableScheduling;
//import org.springframework.scheduling.annotation.Scheduled;
//import org.springframework.beans.factory.annotation.Autowired;
//
//import java.util.concurrent.TimeUnit;
//import java.util.concurrent.Future;
//
//@Configuration
//@EnableScheduling
//public class BusyController {
//    private static final Logger logger = LoggerFactory.getLogger(BusyController.class);
//
//    private final FakeLoadExecutor executor = FakeLoadExecutors.newDefaultExecutor();
//    private Future<Void> execution;
//
//    @Autowired
//    Config config;
//
//    @Scheduled(fixedRate = 1000)
//    public void scheduleFixedDelayTask() {
//        boolean shouldBeBusy = config.getBusy();
//        boolean isBusy = (execution != null);
//
//        if (shouldBeBusy && !isBusy) {
//            logger.info("Going busy!");
//		    FakeLoad fakeload = FakeLoads.create()
//                .lasting(24, TimeUnit.HOURS)
//				.withCpu(80);
//            execution = executor.executeAsync(fakeload);
//        } else if (!shouldBeBusy && isBusy) {
//            logger.info("Stopping busy!");
//            execution.cancel(true);
//            execution = null;
//        }
//    }
//}
