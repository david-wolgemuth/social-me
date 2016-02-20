messengerModule.controller("welcomeController", function (userFactory, $location) {
    var self = this;
    this.currentForm = 'login';
    this.changeForm = function (form) {
        this.error = ""; this.warning = ""; this.message = "";
        this.currentForm = form;
    };
    // Register New User 
    this.register = function (info) {
        this.error = ""; this.warning = ""; this.message = "";
        if (!(info.email && info.passA && info.passB)) {
            this.warning = "All Fields Required";
            return;
        }
        if (!info.handle) {
            this.warning = "User Handle Required, May Only Contain Letters, Numbers, and UnderScores";
        }
        if (info.passA != info.passB) {
            this.warning = "Passwords Do Not Match";
            return;
        }
        user = {
            email: info.email,
            handle: info.handle,
            password: info.passA
        };
        userFactory.create(user, function (success) {
            if (success) {
                self.message = "User Successfully Created";
                for (var key in info) {
                    info[key] = "";
                }
            } else {
                self.error = "Email / Password Already Exists";
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
                self.error = "User / Password Incorrect";
            }
        });
    };
});