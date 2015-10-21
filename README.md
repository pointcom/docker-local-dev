# Docker Local Dev

## Tl;dr

This project aims to build a local environment based on Docker for helping developers to focus on one thing : Code!

## Why?

### Easy to share

First, when you work with a team (more than one person) on the same project, you must use the same versions of every server or service your application needs. 

If you don't, you're going to have issue like this one : 

    Bob : Hey Alice, I have an issue on our app with Elastic Search in my local machine. It doesn't work as expected.
    Alice : Oh really? I don't have any issue on my local machine.
    Bob : What's the version of your Elactic Search server? 
    Alice : 0.90 and yours?
    Bob : 1.0.

I'm sure it sounds familiar to you. isn't it?
One of the goal of this project is to have your servers or services bundled for your app (think about NPM or Bundler but for your app architecture). And to be able to easily upgrade or downgrade them.

### Easy to control

The other goal of this project is to help developers to easily control all the services around your app (servers or your own services).
With the emergence of micro services architecture, the developer's work has changed a lot. 
A while ago, we built "Monolithic" applications that were simple to start and working on in our local machine.

Today, more and more companies embrace "Micro services" architecture and build simple services that do less but do it better. The developer should now run many services and servers before starting to code on some projects.

I'm trying with this project to solve these issues by using new tools and technologies like Docker, Docker compose and Docker machine.


## Getting Started

Coming soon

