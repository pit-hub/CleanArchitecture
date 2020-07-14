using CleanArchitecture.Application.WeatherForecasts.Queries.GetWeatherForecasts;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using MassTransit;

namespace CleanArchitecture.WebUI.Controllers
{
    public class WeatherForecastController : ApiController
    {
        readonly IRequestClient<GetWeatherForecasts> _client;

        public WeatherForecastController(IRequestClient<GetWeatherForecasts> client)
        {
            _client = client;
        }

        [HttpGet]
        public async Task<IEnumerable<WeatherForecast>> Get()
        {
            var response = await _client.GetResponse<WeatherForecasts>(new
            {
                Page = 0
            });

            return response.Message.Forecasts;
        }
    }
}