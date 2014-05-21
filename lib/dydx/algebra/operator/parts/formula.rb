module Dydx
  module Algebra
    module Operator
      module Parts
        module Formula
          %w(+ *).map(&:to_sym).each do |operator|
            define_method(operator) do |x|
              if self.operator == operator
                if f.combinable?(x, operator)
                  f.send(operator, x).send(operator, g)
                elsif g.combinable?(x, operator)
                  g.send(operator, x).send(operator, f)
                else
                  super(x)
                end
              elsif formula?(super_ope(operator)) && x.formula?(super_ope(operator))
                return super(x) if !common_factors(x) || (operator == :* && common_factors(x)[0] != common_factors(x)[1])
                w1, w2 = common_factors(x)
                case operator
                when :+
                  send(w1).send(super_ope(operator), send(rest(w1)).send(operator, x.send(rest(w2))))
                when :*
                  if w1 == :f
                    send(w1).send(super_ope(operator), send(rest(w1)).send(sub_ope(operator), x.send(rest(w2))))
                  elsif w1 == :g
                    send(w1).send(super_ope(operator), send(rest(w1)).send(operator, x.send(rest(w2)))).commutate!
                  end
                end
              elsif formula?(super_ope(operator)) && x.inverse?(operator) && x.x.formula?(super_ope(operator))
                return super(x) if !common_factors(x.x) || (operator == :* && common_factors(x.x)[0] != common_factors(x.x)[1])
                w1, w2 = common_factors(x.x)
                case operator
                when :+
                  send(w1).send(super_ope(operator), send(rest(w1)).send(inverse_ope(operator), x.x.send(rest(w2))))
                when :*
                  if w1 == :f
                    send(w1).send(super_ope(operator), send(rest(w1)).send(inverse_ope(sub_ope(operator)), x.x.send(rest(w2))))
                  elsif w1 == :g
                    send(w1).send(super_ope(operator), send(rest(w1)).send(inverse_ope(operator), x.x.send(rest(w2)))).commutate!
                  end
                end
              else
                super(x)
              end
            end
          end

          def ^(x)
            if multiplication? && openable?(:^, x)
              (f ^ x).send(self.operator, (g ^ x))
            else
              super(x)
            end
          end
        end
      end
    end
  end
end
