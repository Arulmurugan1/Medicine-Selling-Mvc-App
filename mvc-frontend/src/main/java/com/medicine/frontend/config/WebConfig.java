package com.medicine.frontend.config;

import com.medicine.frontend.interceptor.ActivityLogInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {

    private final ActivityLogInterceptor activityLogInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(activityLogInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns("/static/**", "/webjars/**", "/actuator/**");
    }
}
