var messengerModule = angular.module("messengerApp", ["ngRoute", "ui.bootstrap", "ui.bootstrap.modal", "ngAnimate"]);

//Routes Config
messengerModule.config(function($routeProvider){
	$routeProvider
	.when('/welcome', {
		templateUrl: 'views/welcome.html'
	})
	.when('/home', {
		templateUrl: 'views/home.html'
	})
	.when('/users/:id', {
		templateUrl: 'views/user.html'
	})
	.otherwise({
		redirectTo: '/welcome'
	});
});

messengerModule.filter("isoDate", function () {
	return function (input) {
		return Date.parse(input);
	};
});