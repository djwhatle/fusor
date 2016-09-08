import Ember from 'ember';
import request from 'ic-ajax';

export default Ember.Route.extend({
  model() {
    return [request({
      url: '/fusor/api/v21/deployments/' + this.deployment.get('id') + '/compatible_cpu_families',
      type: 'GET',
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": Ember.$('meta[name="csrf-token"]').attr('content')
      }
    })];
  },
  deactivate() {
    return this.send('saveDeployment', null);
  }
});
