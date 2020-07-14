using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using CleanArchitecture.Application.Common.Interfaces;
using CleanArchitecture.Application.TodoLists.Commands.UpdateTodoList;
using FluentValidation;
using MassTransit;
using Microsoft.EntityFrameworkCore;

namespace CleanArchitecture.Application.WeatherForecasts.Queries.GetWeatherForecasts
{
    public class WeatherForecastsConsumer :
        IConsumer<GetWeatherForecasts>
    {
        static readonly string[] Summaries =
        {
            "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
        };

        public async Task Consume(ConsumeContext<GetWeatherForecasts> context)
        {
            var rng = new Random();

            var vm = Enumerable.Range(1, 5).Select(index => new WeatherForecast
            {
                Date = DateTime.Now.AddDays(index),
                TemperatureC = rng.Next(-20, 55),
                Summary = Summaries[rng.Next(Summaries.Length)]
            });

            await context.RespondAsync<WeatherForecasts>(new
            {
                Forecasts = vm
            });
        }
    }

    public class GetWeatherForecastsValidator : AbstractValidator<GetWeatherForecasts>
    {
        public GetWeatherForecastsValidator()
        {
            RuleFor(v => v.Page)
                .GreaterThanOrEqualTo(0).WithMessage("Page must be > 0");
        }
    }

    public interface GetWeatherForecasts
    {
        int Page { get; }
    }

    public interface WeatherForecasts
    {
        WeatherForecast[] Forecasts { get; }
    }
}