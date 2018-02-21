<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="SignUp.Web._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="jumbotron">
        <h1>Have you tried Play with Docker?</h1>
        <p class="lead">A simple, interactive and fun playground to learn Docker.</p>
        <div style="text-align: right">
            <!-- v2 -->
            <a href="https://2018.dockercon.com/" target="_blank">
                <img src="img/dockercon-us-2018.png"/>
            </a>
        </div>
    </div>

    <div class="row">
        <div class="col-md-6">
            <h2>Docker from the comfort of your browser</h2>
            <p>
                Play with Docker (PWD) gives you a configured Docker setup running in the cloud, which you manage from your browser.</p>
            <p>
                There's a playground for just trying things out - like Docker Swarm mode - and there are self-paced training labs too.</p>
            <p>
                <a class="btn btn-default" href="https://labs.play-with-docker.com/" target="_blank">Play with Docker</a> | 
                <a class="btn btn-default" href="http://training.play-with-docker.com/" target="_blank">PWD Classroom</a>
            </p>
        </div>
        <div class="col-md-6">
            <h2>Interested? Get the newsletter!</h2>
            <p>
                Give us your details and we&#39;ll keep you posted.</p>
            <p>
                It only takes 30 seconds to sign up.
            </p>
            <p>
                And we probably won't spam you very much.
            </p>
            <p>
                <a class="btn btn btn-primary btn-lg" href="SignUp.aspx">Sign Up &raquo;</a>
            </p>
        </div>
    </div>

</asp:Content>
