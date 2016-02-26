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

messengerModule.directive("fileread", [function () {
	return {
		scope: {
			fileread: "="
		},
		link: function (scope, element, attributes) {
			element.bind("change", function (changeEvent) {
				var reader = new FileReader();
				reader.onload = function (loadEvent) {
					scope.$apply(function () {
						scope.fileread = loadEvent.target.result;
					});
				};
				reader.readAsDataURL(changeEvent.target.files[0]);
			});
		}
	};
}]);

messengerModule.filter("isoDate", function () {
	return function (input) {
		return Date.parse(input);
	};
});

messengerModule.filter("convoTitle", function () {
	return function (convo, sUser) {
		if (convo.title) {
			return convo.title;
		} else {
			var names = [];
			convo.users.forEach(function (user) {
				if (!sUser || sUser._id != user._id) {
					names.push(user.handle);
				}
			});
			return names.join(" | ");
		}
	};
});