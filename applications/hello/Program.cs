var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "Hello.");
app.MapGet("/{name}", (string name) => $"Hello, {name}.");

app.Run();
