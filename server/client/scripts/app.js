var messengerModule = angular.module("messengerApp", ['ngRoute']);

//Routes Config
messengerModule.config(function($routeProvider){
	$routeProvider
	.when('/welcome', {
		templateUrl: 'views/welcome.html'
	})
	.when('/home', {
		templateUrl: 'views/home.html'
	})
	.when('/conversations/:id', {
		templateUrl: 'views/conversation-view.html'
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