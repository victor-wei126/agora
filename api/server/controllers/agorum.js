const Agorum = require('../models').Agorum;

module.exports = {
  create(req, res) {
    return Agorum
      .create({
        name: req.body.name,
        members: 0,
      })
      .then(agorum => res.status(201).send(agorum))
      .catch(error => res.status(400).send(error));
  },
  list(req, res) {
    return Agorum
      .findAll({
        include: [{
          model: Course,
          as: 'course',
        }],
      })
      .then(agorum => res.status(200).send(agorum))
      .catch(error => res.status(400).send(error));
  },
};