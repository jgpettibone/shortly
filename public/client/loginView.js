Shortly.LoginView = Backbone.View.extend({

  className: 'login',

  template: _.template(' \
    <form action="/loggedin" method="POST"> \
      <input class="user" type="text" name="username"> \
      <input class="login" type="text" name="password"> \
      <input class = "logmein" type="submit" value="log me in!">\
    </form> \
    '),

  events: {
    "submit" : "logMeIn",
  },

  render: function() {
    this.$el.html( this.template() );
    return this;
  },

  logMeIn: function(e) {
    e.preventDefault();
    console.log("in logMeIn")
    var $user = this.$el.find('.user');
    var $pass = this.$el.find('.login');
    var user = new Shortly.User( {username: $user.val(), password: $pass.val()})
    //do something with authenticating these fields.
    $user.val('');
    $pass.val('');
    user.save();
    this.trigger('userloggedin');
  },

  register: function(e) {
    e.preventDefault();
    var $user = this.$el.find('.user').val();
    var $pass = this.$el.find('.login .text');
    //do something to register.
  }

});

