messengerModule.controller("mainController", function ($scope, imageFactory) {
    $scope.currentBackground = "";

    $scope.changeBackground = function () {
        imageFactory.backgroundIndex(function (backgrounds) {
            var i = Math.floor(Math.random() * backgrounds.length);
            // $scope.currentBackground = "{ background: url('background-images/" + backgrounds[i] + "'); }";
            $scope.currentBackground = "background: url('images/backgrounds/" + backgrounds[i] + "');";
            console.log($scope.currentBackground);
        });
    };
    $scope.changeBackground();
});