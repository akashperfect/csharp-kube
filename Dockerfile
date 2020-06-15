FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /src
COPY ["csharp-kube.csproj", "./"]
RUN dotnet restore "./csharp-kube.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "csharp-kube.csproj" -c Build -o /app/build

FROM build AS publish
RUN dotnet publish "csharp-kube.csproj" -c Build -o /app/publish

FROM base AS final

RUN apt-get update && apt-get -y install procps
RUN curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l /vsdbg

WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "csharp-kube.dll"]
