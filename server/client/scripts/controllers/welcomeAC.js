messengerModule.controller("welcomeController", function (userFactory, $location) {
    var self = this;
    this.errors = {};
    this.messages = {};
    this.currentForm = 'login';
    // Register New User 
    this.register = function (info) {
        this.errors = {};
        this.messages = {};
        if (!(info.email && info.passA && info.passB)) {
            this.errors.registration = "All Fields Required";
            return;
        }
        if (!info.handle) {
            this.errors.registration = "User Handle Required, May Only Contain Letters, Numbers, and UnderScores";
        }
        if (info.passA != info.passB) {
            this.errors.registration = "Passwords Do Not Match";
            return;
        }
        user = {
            email: info.email,
            handle: info.handle,
            password: info.passA
        };
        userFactory.create(user, function (success) {
            if (success) {
                self.messages.registration = "User Successfully Created";
                for (var key in info) {
                    info[key] = "";
                }
            } else {
                self.errors.registration = "Email / Password Already Exists";
                info.passA = ""; info.passB = "";
            }
        });
    };
    this.login = function (info) {
        if (!info.password || !info.user) {
            return;
        }
        userFactory.login(info, function (success) {
            if (success) {
                $location.path("/home");
            } else {
                self.errors.login = "User / Password Incorrect"
            }
        });
    };
});