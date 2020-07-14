using AutoMapper;
using CleanArchitecture.Application.Common.Behaviours;
using FluentValidation;
using MediatR;
using Microsoft.Extensions.DependencyInjection;
using System.Reflection;
using CleanArchitecture.Application.WeatherForecasts.Queries.GetWeatherForecasts;
using MassTransit;

namespace CleanArchitecture.Application
{
    public static class DependencyInjection
    {
        public static IServiceCollection AddApplication(this IServiceCollection services)
        {
            services.AddAutoMapper(Assembly.GetExecutingAssembly());
            services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());
            services.AddMediatR(Assembly.GetExecutingAssembly());
            services.AddTransient(typeof(IPipelineBehavior<,>), typeof(PerformanceBehaviour<,>));
            services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
            services.AddTransient(typeof(IPipelineBehavior<,>), typeof(UnhandledExceptionBehaviour<,>));

            services.AddMediator(x =>
            {
                x.ConfigureMediator((context, cfg) =>
                {
                    cfg.ConnectConsumerConfigurationObserver(new LoggingConsumerConfigurationObserver());
                    cfg.ConnectConsumerConfigurationObserver(new ValidationConsumerConfigurationObserver());

//                    cfg.UseConsumeFilter(typeof(ScopedLoggingFilter<>), context);
                });

                x.AddConsumers(Assembly.GetExecutingAssembly());

                x.AddRequestClient<GetWeatherForecasts>();
            });

            return services;
        }
    }
}