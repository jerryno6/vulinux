
FROM mcr.microsoft.com/dotnet/core/aspnet:2.2 AS base
FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS build

WORKDIR /app
COPY "MyCompany.MyService/" "MyCompany.MyService/"
COPY "MyCompany.MyService.Models/" "MyCompany.MyService.Models/"
COPY "MyCompany.MyService.IntegrationTests/" "MyCompany.MyService.IntegrationTests/"

COPY NuGet.Config ./

WORKDIR /app/MyCompany.MyService.IntegrationTests
RUN dotnet restore

ENTRYPOINT ["dotnet", "test", "MyCompany.MyService.IntegrationTests.csproj"]
