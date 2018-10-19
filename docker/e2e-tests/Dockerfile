# escape=`
FROM microsoft/dotnet-framework:4.7.2-sdk AS builder

WORKDIR C:\src\SignUp.EndToEndTests
COPY src\SignUp.EndToEndTests\packages.config .
RUN nuget restore packages.config -PackagesDirectory ..\packages

COPY src C:\src
RUN msbuild SignUp.EndToEndTests.csproj /p:OutputPath=C:\out

# test runner
FROM sixeyed/nunit:3.6.1-windowsservercore-ltsc2016

WORKDIR /e2e-tests
CMD nunit3-console SignUp.EndToEndTests.dll

ENV SignUpPage:Url="http://signup-web/app/SignUp" `
    ConnectionStrings:SignUpDb="Server=signup-db;Database=SignUp;User Id=sa;Password=DockerCon!!!"

COPY --from=builder C:\out .