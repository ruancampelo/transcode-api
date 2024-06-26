
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base

RUN apt-get update 
RUN apt-get install -y ffmpeg
	
WORKDIR /app
WORKDIR /transcoder/input 
WORKDIR /transcoder/output

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src
COPY [ "src", "."]

RUN dotnet restore "Transcoder.API/Transcoder.API.csproj"
COPY . .
WORKDIR "/src/Transcoder.API"

RUN dotnet build "Transcoder.API.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "Transcoder.API.csproj" -c Release -o /app

FROM base AS final

WORKDIR /app
COPY --from=publish /app .
ENV ASPNETCORE_URLS="http://*:5101"

EXPOSE 5101
ENTRYPOINT ["dotnet", "Transcoder.API.dll"]