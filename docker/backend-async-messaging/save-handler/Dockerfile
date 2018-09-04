# escape=`
FROM microsoft/dotnet-framework:4.7.2-sdk AS builder

WORKDIR C:\src
COPY signup\src\SignUp.sln .
COPY signup\src\SignUp.Core\SignUp.Core.csproj .\SignUp.Core\
COPY signup\src\SignUp.Entities\SignUp.Entities.csproj .\SignUp.Entities\
COPY signup\src\SignUp.Messaging\SignUp.Messaging.csproj .\SignUp.Messaging\
COPY signup\src\SignUp.Model\SignUp.Model.csproj .\SignUp.Model\
COPY signup\src\SignUp.Model\packages.config .\SignUp.Model\
COPY signup\src\SignUp.MessageHandlers.SaveProspect\SignUp.MessageHandlers.SaveProspect.csproj .\SignUp.MessageHandlers.SaveProspect\
COPY signup\src\SignUp.MessageHandlers.SaveProspect\packages.config .\SignUp.MessageHandlers.SaveProspect\
RUN nuget restore SignUp.sln

COPY signup\src C:\src
RUN msbuild SignUp.MessageHandlers.SaveProspect\SignUp.MessageHandlers.SaveProspect.csproj /p:OutputPath=c:\out\save-prospect\SaveProspectHandler

# app image
FROM microsoft/dotnet-framework:4.7.2-runtime

WORKDIR /save-prospect-handler
CMD .\SignUp.MessageHandlers.SaveProspect.exe

COPY --from=builder C:\out\save-prospect\SaveProspectHandler .