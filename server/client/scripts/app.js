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

messengerModule.filter("convoTitle", function () {
	return function (convo) {
		if (convo.title) {
			return convo.title;
		} else {
			var names = [];
			convo.users.forEach(function (user) {
				names.push(user.handle);
			});
			return names.join(" | ");
		}
	};
});