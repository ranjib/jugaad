module Jugaad
  module LXC
    module Extensions
      module Core
        def ipv4
          ::LXC.run('ls','--fancy','--fancy-format ipv4', '^'+name+'$').lines.drop(2).first.strip
        end
      end
    end
  end
end
