Shortly.LoginView = Backbone.View.extend({

  className: 'login',

  template: _.template(' \
    <form action="/loggedin" method="POST"> \
      <input class="user" type="text" name="username"> \
      <input class="login" type="text" name="password"> \
      <input type="submit" class = "logmein" value="log me in!">\
      <a href="#">Register for Shortly</a>\
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
    debugger;
    e.preventDefault();
    var $user = this.$el.find('.user').val();
    var $pass = this.$el.find('.login').val();
    //do something with authenticating these fields.
  },

  register: function(e) {
    e.preventDefault();
    var $user = this.$el.find('.user').val();
    var $pass = this.$el.find('.login .text');
    //do something to register.
  }

});

